#!/bin/bash
set -e

# ── Cores ──────────────────────────────────────────────────
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

step() {
  echo -e "\n${BLUE}══════════════════════════════════════${NC}"
  echo -e "  ${GREEN}$1${NC}"
  echo -e "${BLUE}══════════════════════════════════════${NC}\n"
}

info() { echo -e "  ${YELLOW}→${NC} $1"; }

# ── 1. Xcode CLI Tools ────────────────────────────────────
step "1/12 — Xcode CLI Tools"
if xcode-select -p &>/dev/null; then
  info "Já instalado"
else
  xcode-select --install
  echo "Aguarde a instalação do Xcode CLI Tools e rode o script novamente."
  exit 0
fi

# ── 2. Homebrew ────────────────────────────────────────────
step "2/12 — Homebrew"
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  info "Já instalado: $(brew --version | head -1)"
fi

brew analytics off
brew doctor || true

# Dependências de compilação
brew install openssl readline sqlite3 xz zlib tcl-tk

# ── 3. iTerm2 + Fontes ────────────────────────────────────
step "3/12 — iTerm2 + Fontes"
brew install --cask iterm2 2>/dev/null || info "iTerm2 já instalado"
brew install --cask font-jetbrains-mono-nerd-font 2>/dev/null || info "Fonte já instalada"
brew install --cask font-meslo-lg-nerd-font 2>/dev/null || info "Fonte já instalada"

# Catppuccin colors
curl -sL -o ~/catppuccin-mocha.itermcolors \
  https://raw.githubusercontent.com/catppuccin/iterm/main/colors/catppuccin-mocha.itermcolors
info "Tema salvo em ~/catppuccin-mocha.itermcolors"
info "Importar: iTerm2 → Settings → Profiles → Colors → Import"

# ── 4. Zsh ─────────────────────────────────────────────────
step "4/12 — Zsh"
brew install zsh

if ! grep -q '/opt/homebrew/bin/zsh' /etc/shells; then
  sudo sh -c 'echo /opt/homebrew/bin/zsh >> /etc/shells'
fi

if [[ "$SHELL" != */opt/homebrew/bin/zsh ]]; then
  chsh -s /opt/homebrew/bin/zsh
  info "Shell alterado para /opt/homebrew/bin/zsh"
else
  info "Já é o shell padrão"
fi

# ── 5. Oh My Zsh + Plugins ────────────────────────────────
step "5/12 — Oh My Zsh + Plugins"

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  info "Oh My Zsh já instalado"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

declare -A ZSH_PLUGINS=(
  [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
  [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting"
  [zsh-completions]="https://github.com/zsh-users/zsh-completions"
  [you-should-use]="https://github.com/MichaelAquilina/zsh-you-should-use"
)

for plugin in "${!ZSH_PLUGINS[@]}"; do
  if [[ -d "$ZSH_CUSTOM/plugins/$plugin" ]]; then
    info "$plugin (atualizando)"
    git -C "$ZSH_CUSTOM/plugins/$plugin" pull --quiet
  else
    info "$plugin (instalando)"
    git clone --quiet "${ZSH_PLUGINS[$plugin]}" "$ZSH_CUSTOM/plugins/$plugin"
  fi
done

# ── 6. CLI Tools ───────────────────────────────────────────
step "6/12 — CLI Tools"
brew install \
  eza bat ripgrep fd fzf zoxide tldr jq yq \
  httpie difftastic dust procs bottom git-delta \
  neovim atuin starship

# fzf keybindings
"$(brew --prefix)"/opt/fzf/install --all --no-bash --no-fish 2>/dev/null || true

# ── 7. Python ──────────────────────────────────────────────
step "7/12 — Python (pyenv + uv + ruff)"
brew install pyenv uv ruff

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash 2>/dev/null || pyenv init -)"

PY_VERSION=$(pyenv install --list | grep -E '^\s*3\.12\.' | tail -1 | tr -d ' ')
pyenv install -s "$PY_VERSION"
pyenv global "$PY_VERSION"
info "Python: $PY_VERSION"

uv tool install ipython 2>/dev/null || true
uv tool install pre-commit 2>/dev/null || true

# ── 8. Node ────────────────────────────────────────────────
step "8/12 — Node (Volta + Bun + Biome)"
brew install volta bun biome

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

volta install node@lts
volta install yarn@4
volta install pnpm
volta install typescript
info "Node: $(node --version)"

# ── 9. Yarn Berry — Config Global ─────────────────────────
step "9/12 — Yarn Berry (config global)"

mkdir -p ~/.yarn
cat > ~/.yarnrc.yml << 'YARNRC'
# Preferências globais do Yarn Berry
enableTelemetry: false
enableGlobalCache: true
compressionLevel: mixed
nodeLinker: node-modules
YARNRC
info "Config global criada em ~/.yarnrc.yml"
info "nodeLinker: node-modules (compatibilidade máxima)"
info "Para PnP: altere nodeLinker para 'pnp' no .yarnrc.yml do projeto"

# ── 10. Go ─────────────────────────────────────────────────
step "10/12 — Go"
brew install go

export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
go install github.com/air-verse/air@latest
go install github.com/swaggo/swag/cmd/swag@latest
go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
info "Go: $(go version | awk '{print $3}')"

# ── 11. Docker & Databases ────────────────────────────────
step "11/12 — Docker & Databases"
brew install --cask docker 2>/dev/null || info "Docker Desktop já instalado"
brew install lazydocker dive ctop
brew install pgcli mycli litecli mongosh redis
brew install grpcurl websocat

# ── 12. Configs ────────────────────────────────────────────
step "12/12 — Configurações globais"

# Starship
mkdir -p ~/.config
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
success_symbol = "[❯](green)"
error_symbol = "[❯](red)"

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
format = "[⏱ $duration]($style) "
style = "bold yellow"
STARSHIP
info "Starship config criado"

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
info "Git config aplicado"

# ── Done ───────────────────────────────────────────────────
step "Setup completo!"
echo ""
echo "Próximos passos:"
echo "  1. Copie o .zshrc da seção 9 do doc para ~/.zshrc"
echo "  2. source ~/.zshrc"
echo "  3. Configure git user:"
echo "     git config --global user.name \"Seu Nome\""
echo "     git config --global user.email \"seu@email.com\""
echo "  4. iTerm2: selecione a fonte JetBrainsMono Nerd Font (size 14)"
echo "  5. iTerm2: importe ~/catppuccin-mocha.itermcolors"
echo "  6. Use 'update-all' para manter tudo atualizado"
echo "  7. Em projetos Yarn Berry: yarn set version stable"
echo ""
echo "Versões instaladas:"
echo "  Python : $(python --version 2>&1)"
echo "  Node   : $(node --version 2>&1)"
echo "  Yarn   : $(yarn --version 2>&1)"
echo "  Go     : $(go version 2>&1 | awk '{print $3}')"
echo "  Brew   : $(brew --version | head -1)"
echo "  uv     : $(uv --version 2>&1)"
echo "  Ruff   : $(ruff --version 2>&1)"
