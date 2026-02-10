#!/bin/bash

# ── Verificacao: macOS Apple Silicon ───────────────────────
if [[ "$(uname)" != "Darwin" ]]; then
  echo "Este script e exclusivo para macOS. Abortando."
  exit 1
fi

if [[ "$(uname -m)" != "arm64" ]]; then
  echo "Este script e exclusivo para Apple Silicon (M1/M2/M3/M4)."
  echo "Arquitetura detectada: $(uname -m)"
  exit 1
fi

# ── Cores e helpers ────────────────────────────────────────
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

TOTAL_STEPS=12
ERRORS=0

step() {
  echo -e "\n${BLUE}══════════════════════════════════════${NC}"
  echo -e "  ${GREEN}$1${NC}"
  echo -e "${BLUE}══════════════════════════════════════${NC}\n"
}

info()  { echo -e "  ${YELLOW}→${NC} $1"; }
ok()    { echo -e "  ${GREEN}✔${NC} $1"; }
fail()  { echo -e "  ${RED}✘${NC} $1"; ERRORS=$((ERRORS + 1)); }

# Instala plugin do Oh My Zsh (clone ou pull)
install_zsh_plugin() {
  local name="$1"
  local url="$2"
  local dir="${ZSH_CUSTOM}/plugins/${name}"

  if [[ -d "$dir" ]]; then
    info "$name (atualizando)"
    git -C "$dir" pull --quiet || fail "$name: falha ao atualizar"
  else
    info "$name (instalando)"
    git clone --quiet "$url" "$dir" || fail "$name: falha ao clonar"
  fi
}

# ── 1. Xcode CLI Tools ────────────────────────────────────
step "1/${TOTAL_STEPS} — Xcode CLI Tools"
if xcode-select -p &>/dev/null; then
  ok "Ja instalado"
else
  xcode-select --install
  echo "Aguarde a instalacao do Xcode CLI Tools e rode o script novamente."
  exit 0
fi

# ── 2. Homebrew ────────────────────────────────────────────
step "2/${TOTAL_STEPS} — Homebrew"
if command -v brew &>/dev/null; then
  ok "Ja instalado: $(brew --version | head -1)"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

brew analytics off 2>/dev/null
brew doctor 2>/dev/null || true

info "Dependencias de compilacao"
brew install openssl readline sqlite3 xz zlib tcl-tk 2>/dev/null || true

# ── 3. iTerm2 + Fontes ────────────────────────────────────
step "3/${TOTAL_STEPS} — iTerm2 + Fontes"
brew install --cask iterm2 2>/dev/null || ok "iTerm2 ja instalado"
brew install --cask font-jetbrains-mono-nerd-font 2>/dev/null || ok "JetBrains font ja instalada"
brew install --cask font-meslo-lg-nerd-font 2>/dev/null || ok "Meslo font ja instalada"

if [[ ! -f ~/catppuccin-mocha.itermcolors ]]; then
  curl -sL -o ~/catppuccin-mocha.itermcolors \
    https://raw.githubusercontent.com/catppuccin/iterm/main/colors/catppuccin-mocha.itermcolors
  info "Tema salvo em ~/catppuccin-mocha.itermcolors"
else
  ok "Tema Catppuccin ja baixado"
fi

# ── 4. Zsh ─────────────────────────────────────────────────
step "4/${TOTAL_STEPS} — Zsh"
brew install zsh 2>/dev/null || true

if ! grep -q '/opt/homebrew/bin/zsh' /etc/shells 2>/dev/null; then
  sudo sh -c 'echo /opt/homebrew/bin/zsh >> /etc/shells'
  info "Adicionado ao /etc/shells"
else
  ok "Ja registrado em /etc/shells"
fi

if [[ "$SHELL" != */opt/homebrew/bin/zsh ]]; then
  chsh -s /opt/homebrew/bin/zsh
  info "Shell padrao alterado"
else
  ok "Ja e o shell padrao"
fi

# ── 5. Oh My Zsh + Plugins ────────────────────────────────
step "5/${TOTAL_STEPS} — Oh My Zsh + Plugins"

if [[ -d "$HOME/.oh-my-zsh" ]]; then
  ok "Oh My Zsh ja instalado"
else
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

install_zsh_plugin "zsh-autosuggestions"     "https://github.com/zsh-users/zsh-autosuggestions"
install_zsh_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"
install_zsh_plugin "zsh-completions"         "https://github.com/zsh-users/zsh-completions"
install_zsh_plugin "you-should-use"          "https://github.com/MichaelAquilina/zsh-you-should-use"

# ── 6. CLI Tools ───────────────────────────────────────────
step "6/${TOTAL_STEPS} — CLI Tools"
brew install \
  eza bat ripgrep fd fzf zoxide tldr jq yq \
  httpie difftastic dust procs bottom git-delta \
  neovim atuin starship 2>/dev/null || true

if [[ ! -f ~/.fzf.zsh ]]; then
  "$(brew --prefix)"/opt/fzf/install --all --no-bash --no-fish 2>/dev/null || true
  info "fzf keybindings instalados"
else
  ok "fzf keybindings ja configurados"
fi

# ── 7. Python ──────────────────────────────────────────────
step "7/${TOTAL_STEPS} — Python (pyenv + uv + ruff)"
brew install pyenv uv ruff 2>/dev/null || true

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash 2>/dev/null || pyenv init - 2>/dev/null || true)"

PY_VERSION=$(pyenv install --list 2>/dev/null | grep -E '^\s*3\.12\.' | tail -1 | tr -d ' ')
if [[ -n "$PY_VERSION" ]]; then
  pyenv install -s "$PY_VERSION"
  pyenv global "$PY_VERSION"
  ok "Python: $PY_VERSION"
else
  fail "Nao foi possivel determinar versao do Python"
fi

uv tool install ipython 2>/dev/null || true
uv tool install pre-commit 2>/dev/null || true

# ── 8. Node ────────────────────────────────────────────────
step "8/${TOTAL_STEPS} — Node (Volta + Bun + Biome)"
brew install volta bun biome 2>/dev/null || true

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

volta install node@lts 2>/dev/null || fail "volta install node@lts"
volta install yarn@4 2>/dev/null || fail "volta install yarn@4"
volta install pnpm 2>/dev/null || fail "volta install pnpm"
volta install typescript 2>/dev/null || fail "volta install typescript"
ok "Node: $(node --version 2>&1)"

# ── 9. Yarn Berry — Config Global ─────────────────────────
step "9/${TOTAL_STEPS} — Yarn Berry (config global)"

if [[ -f ~/.yarnrc.yml ]]; then
  ok "Config global ja existe em ~/.yarnrc.yml"
else
  mkdir -p ~/.yarn
  cat > ~/.yarnrc.yml << 'YARNRC'
enableTelemetry: false
enableGlobalCache: true
compressionLevel: mixed
nodeLinker: node-modules
YARNRC
  ok "Config global criada em ~/.yarnrc.yml"
fi

# ── 10. Go ─────────────────────────────────────────────────
step "10/${TOTAL_STEPS} — Go"
brew install go 2>/dev/null || true

export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

go install golang.org/x/tools/gopls@latest 2>/dev/null || fail "gopls"
go install github.com/go-delve/delve/cmd/dlv@latest 2>/dev/null || fail "delve"
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest 2>/dev/null || fail "golangci-lint"
go install github.com/air-verse/air@latest 2>/dev/null || fail "air"
go install github.com/swaggo/swag/cmd/swag@latest 2>/dev/null || fail "swag"
go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest 2>/dev/null || fail "sqlc"
ok "Go: $(go version 2>&1 | awk '{print $3}')"

# ── 11. Docker & Databases ────────────────────────────────
step "11/${TOTAL_STEPS} — Docker & Databases"
brew install --cask docker 2>/dev/null || ok "Docker Desktop ja instalado"
brew install lazydocker dive ctop 2>/dev/null || true
brew install pgcli mycli litecli mongosh redis 2>/dev/null || true
brew install grpcurl websocat 2>/dev/null || true

# ── 12. Configs ────────────────────────────────────────────
step "12/${TOTAL_STEPS} — Configuracoes globais"

# Starship
mkdir -p ~/.config
if [[ -f ~/.config/starship.toml ]]; then
  ok "Starship config ja existe"
else
  cat > ~/.config/starship.toml << 'STARSHIP'
format = """
$directory\
$git_branch\
$git_status\
$python\
$nodejs\
$golang\
$docker_context\
$aws\
$cmd_duration\
$line_break\
$character"""

[character]
success_symbol = "[>](green)"
error_symbol = "[>](red)"

[directory]
truncation_length = 3
truncate_to_repo = true
style = "bold cyan"

[git_branch]
symbol = " "
style = "bold purple"

[git_status]
style = "bold red"
format = '([$all_status$ahead_behind]($style) )'

[python]
symbol = " "
format = '[${symbol}${pyenv_prefix}(${version} )(\($virtualenv\) )]($style)'
style = "bold yellow"

[nodejs]
symbol = " "
format = '[$symbol($version )]($style)'
style = "bold green"

[golang]
symbol = " "
format = '[$symbol($version )]($style)'
style = "bold cyan"

[docker_context]
symbol = " "
format = '[$symbol$context]($style) '
style = "bold blue"

[aws]
symbol = " "
format = '[$symbol($profile )(\($region\) )]($style)'
style = "bold orange"

[cmd_duration]
min_time = 2_000
format = "[~ $duration]($style) "
style = "bold yellow"
STARSHIP
  ok "Starship config criado"
fi

# Git
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global push.autoSetupRemote true
git config --global fetch.prune true
git config --global rebase.autoStash true
git config --global rerere.enabled true
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.side-by-side true
git config --global delta.line-numbers true
git config --global merge.conflictstyle zdiff3
git config --global alias.st "status -sb"
git config --global alias.co "checkout"
git config --global alias.br "branch"
git config --global alias.ci "commit"
git config --global alias.unstage "reset HEAD --"
git config --global alias.last "log -1 HEAD --stat"
git config --global alias.lg "log --oneline --graph --decorate -20"
git config --global alias.amend "commit --amend --no-edit"
git config --global alias.wip '!git add -A && git commit -m "wip"'
git config --global alias.undo "reset --soft HEAD~1"
git config --global alias.cleanup '!git branch --merged main | grep -v "main" | xargs -n 1 git branch -d'
ok "Git config aplicado"

# ── Done ───────────────────────────────────────────────────
echo ""
if [[ $ERRORS -gt 0 ]]; then
  step "Setup concluido com ${ERRORS} erro(s)"
  echo -e "  ${RED}Rode novamente para tentar os passos que falharam.${NC}"
else
  step "Setup completo!"
fi

echo ""
echo "Proximos passos:"
echo "  1. Copie o .zshrc da secao 5 do setup.md para ~/.zshrc"
echo "  2. source ~/.zshrc"
echo "  3. Configure git user:"
echo "     git config --global user.name \"Seu Nome\""
echo "     git config --global user.email \"seu@email.com\""
echo "  4. iTerm2: selecione a fonte JetBrainsMono Nerd Font (size 14)"
echo "  5. iTerm2: importe ~/catppuccin-mocha.itermcolors"
echo "  6. Use 'update-all' para manter tudo atualizado"
echo ""
echo "Versoes instaladas:"
echo "  Python : $(python --version 2>&1)"
echo "  Node   : $(node --version 2>&1)"
echo "  Yarn   : $(yarn --version 2>&1)"
echo "  Go     : $(go version 2>&1 | awk '{print $3}')"
echo "  Brew   : $(brew --version 2>&1 | head -1)"
echo "  uv     : $(uv --version 2>&1)"
echo "  Ruff   : $(ruff --version 2>&1)"
