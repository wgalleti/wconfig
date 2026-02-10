# macOS Dev Environment — Configuracao

> **Requisito:** macOS com Apple Silicon (M1/M2/M3/M4). Os scripts usam paths do Homebrew em `/opt/homebrew` (arm64). Nao compativel com Intel.

## Quick Start (Mac formatado)

Copie e cole no Terminal (ja vem instalado no macOS):

```bash
# 1. Xcode CLI Tools (necessario para git e compilacao)
xcode-select --install
```

Aguarde a instalacao terminar, depois continue:

```bash
# 2. Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# 3. Git (versao do Homebrew)
brew install git

# 4. Clonar este repo
git clone git@github.com:wgalleti/wconfig.git ~/wconfig
cd ~/wconfig/mac

# 5. Rodar o setup
chmod +x setup.sh
./setup.sh
```

> Se ainda nao tem SSH key configurada, use HTTPS:
> `git clone https://github.com/wgalleti/wconfig.git ~/wconfig`

Apos o script, siga as configuracoes manuais abaixo.

---

## 1. Git — Identidade

O script configura tudo exceto a identidade (pessoal de cada máquina):

```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"
```

---

## 2. iTerm2 — Configuracoes manuais

### 3.1 Fonte

**Settings → Profiles → Text → Font → JetBrainsMono Nerd Font** (tamanho 14).

### 3.2 Esquema de cores

O script baixa `~/catppuccin-mocha.itermcolors`. Importar:

**Settings → Profiles → Colors → Color Presets → Import** → selecionar o arquivo.

Outras opções: **Tokyo Night**, **Dracula**, **Nord**.

### 3.3 Configurações recomendadas

Abra iTerm2 → `Settings` (Cmd + ,):

| Seção | Configuração | Valor |
|-------|-------------|-------|
| Appearance → General | Theme | **Minimal** |
| Appearance → Tabs | Tab bar location | **Bottom** |
| Profiles → General | Working Directory | **Reuse previous session's directory** |
| Profiles → Text | Font size | **14** |
| Profiles → Window | Columns x Rows | **140 x 35** |
| Profiles → Window | Transparency | **5-10%** (sutil) |
| Profiles → Terminal | Scrollback lines | **10000** |
| Keys → Hotkey | Hotkey Window | **Alt Space** (terminal dropdown) |

### 3.4 Atalhos

| Atalho | Acao |
|--------|------|
| Cmd D | Split vertical |
| Cmd Shift D | Split horizontal |
| Cmd T | Nova aba |
| Cmd [ / ] | Navegar entre paineis |
| Cmd Shift Enter | Maximizar/restaurar painel |
| Cmd ; | Autocomplete (iTerm) |
| Cmd Shift H | Historico de paste |

**Dica:** crie profiles diferentes para Producao (fundo vermelho sutil) vs Dev em **Settings → Profiles → +**. Troque com `Cmd O`.

---

## 3. Starship — Prompt

O script ja cria `~/.config/starship.toml`. Para customizar:

```toml
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
```

**Alternativa — Powerlevel10k:**

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
# No .zshrc: ZSH_THEME="powerlevel10k/powerlevel10k"
# Rodar: p10k configure
```

---

## 4. Yarn Berry — Uso em projetos

O script configura o Yarn Berry globalmente (`~/.yarnrc.yml`). Para cada projeto:

```bash
# Ativar Berry no projeto
yarn set version stable

# Verificar versao
yarn --version
```

**Config por projeto** — `.yarnrc.yml` (criada automaticamente, pode customizar):

```yaml
# node_modules tradicional (compatibilidade maxima)
nodeLinker: node-modules

# Cache global compartilhado
enableGlobalCache: true

# Compressao do cache
compressionLevel: mixed

# Checksums para integridade
checksumBehavior: update

# Telemetria desabilitada
enableTelemetry: false
```

> **PnP vs node_modules:** O padrao do Berry e **Plug'n'Play** (sem `node_modules`). E mais rapido, mas nem todas as ferramentas suportam. Use `nodeLinker: node-modules` para maxima compatibilidade, ou `nodeLinker: pnp` se o projeto suportar.

**Comandos uteis:**

```bash
yarn upgrade-interactive                # atualizar deps interativamente
yarn dlx @yarnpkg/doctor                # verificar integridade
yarn plugin import interactive-tools    # plugin upgrade-interactive
yarn plugin import typescript           # auto @types/*
yarn plugin import workspace-tools      # workspaces
```

**`.gitignore` para projetos Yarn Berry:**

```gitignore
.yarn/*
!.yarn/patches
!.yarn/plugins
!.yarn/releases
!.yarn/sdks
!.yarn/versions
.pnp.*
```

---

## 5. O .zshrc

Copiar para `~/.zshrc` e rodar `source ~/.zshrc`:

```bash
# ============================================================
# OH MY ZSH
# ============================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"  # Ignorado pelo Starship
# ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  # Core
  git
  aliases
  you-should-use
  zsh-autosuggestions
  zsh-completions

  # Dev
  docker
  docker-compose
  kubectl
  python
  pip
  node
  npm
  yarn

  # macOS
  brew
  macos

  # Utils
  encode64
  urltools
  copypath
  copyfile
  web-search
  sudo
  jsontools

  # DEVE SER O ULTIMO
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# ============================================================
# AMBIENTE
# ============================================================
eval "$(/opt/homebrew/bin/brew shellenv)"

export PYENV_ROOT="$HOME/.pyenv"
export VOLTA_HOME="$HOME/.volta"
export BUN_INSTALL="$HOME/.bun"
export GOPATH="$HOME/go"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export GEM_HOME="$HOME/.gem"
export JAVA_HOME="/opt/homebrew/opt/openjdk@17"

export PIPENV_VENV_IN_PROJECT=1
export PRE_COMMIT_ALLOW_NO_CONFIG=1
export AWS_DEFAULT_REGION=us-east-1
export EDITOR='nvim'

# OpenSSL do Homebrew (necessario para pyenv compilar Python)
export LDFLAGS="-L/opt/homebrew/opt/openssl@3/lib"
export CPPFLAGS="-I/opt/homebrew/opt/openssl@3/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/openssl@3/lib/pkgconfig"

# Brew otimizacoes
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ENV_HINTS=1

# ============================================================
# PATH (typeset -U remove duplicatas)
# ============================================================
typeset -U PATH

path=(
  "$HOME/.local/bin"
  "$PYENV_ROOT/bin"
  "$VOLTA_HOME/bin"
  "$BUN_INSTALL/bin"
  "$GOPATH/bin"
  "$GEM_HOME/bin"
  "$JAVA_HOME/bin"
  "/opt/homebrew/opt/libpq/bin"
  "/opt/homebrew/opt/php@8.3/bin"
  "/opt/homebrew/opt/php@8.3/sbin"
  "/opt/homebrew/opt/ruby/bin"
  "/opt/homebrew/opt/coreutils/libexec/gnubin"
  "/opt/homebrew/opt/mysql-client/bin"
  "$HOME/.codeium/windsurf/bin"
  "$HOME/.docker/bin"
  "$ANDROID_HOME/emulator"
  "$ANDROID_HOME/platform-tools"
  "$ANDROID_HOME/cmdline-tools/latest/bin"
  $path
)

export DYLD_LIBRARY_PATH="/opt/homebrew/lib:$DYLD_LIBRARY_PATH"
export DYLD_FALLBACK_LIBRARY_PATH="/opt/homebrew/lib"

# ============================================================
# ALIASES — Git
# ============================================================
alias g='git'
alias lg='lazygit'

# ============================================================
# ALIASES — Docker
# ============================================================
alias dc='docker compose'
alias ld='lazydocker'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dprune='docker system prune -af --volumes'
alias dlogs='docker compose logs -f --tail=50'

# ============================================================
# ALIASES — Python / Django
# ============================================================
alias avv='source .venv/bin/activate'
alias pm='python $VIRTUAL_ENV/../manage.py'
alias upm='uv run manage.py'
alias py='python'
alias ipy='ipython'
alias ptest='uv run pytest -v'
alias pcheck='ruff check . && ruff format --check .'
alias pfix='ruff check . --fix && ruff format .'

# ============================================================
# ALIASES — Go
# ============================================================
alias gorun='go run .'
alias gobuild='go build -o bin/ .'
alias gotest='go test ./... -v'
alias golint='golangci-lint run ./...'
alias gomod='go mod tidy'

# ============================================================
# ALIASES — Node / JS
# ============================================================
alias n14='volta install node@14'
alias n22='volta install node@22'
alias nlts='volta install node@lts'
alias nr='npm run'
alias yd='yarn dev'
alias ys='yarn start'
alias yb='yarn build'

# ============================================================
# ALIASES — Brew
# ============================================================
alias bup='brew update && brew upgrade && brew cleanup && brew doctor'
alias bs='brew search'
alias bi='brew install'

# ============================================================
# ALIASES — Ferramentas modernas
# ============================================================
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --git --icons --group-directories-first'
alias lt='eza --tree --level=2 --icons'
alias cat='bat --paging=never'
alias grep='rg'
alias find='fd'
alias top='btm'
alias du='dust'
alias ps='procs'
alias diff='difft'

# ============================================================
# ALIASES — Databases
# ============================================================
alias pg='pgcli'
alias mydb='mycli'
alias lite='litecli'

# ============================================================
# ALIASES — Editor
# ============================================================
alias vim='nvim'
alias vi='nvim'

# ============================================================
# ALIASES — Utilidades
# ============================================================
alias kc='kubectl'
alias dnsclean='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
alias dvenv='find . -type d -name ".venv" -exec rm -rf {} +'
alias dnm='find . -type d -name "node_modules" -exec rm -rf {} +'
alias reload='source ~/.zshrc'
alias path='echo $PATH | tr ":" "\n" | nl'
alias ports='lsof -iTCP -sTCP:LISTEN -n -P'
alias myip='curl -s ifconfig.me'

# ============================================================
# UPDATE-ALL — Atualiza tudo de uma vez
# ============================================================
update-all() {
  echo "======================================"
  echo "  Homebrew"
  echo "======================================"
  brew update
  brew upgrade
  brew cleanup -s
  brew autoremove
  brew doctor || true

  echo ""
  echo "======================================"
  echo "  Python (pyenv -> latest 3.12.x)"
  echo "======================================"
  local py_latest=$(pyenv install --list | grep -E '^\s*3\.12\.' | tail -1 | tr -d ' ')
  local py_current=$(pyenv global)
  if [[ "$py_latest" != "$py_current" ]]; then
    echo "Atualizando: $py_current -> $py_latest"
    pyenv install -s "$py_latest" && pyenv global "$py_latest"
  else
    echo "Ja na versao mais recente: $py_current"
  fi

  echo ""
  echo "======================================"
  echo "  uv + tools"
  echo "======================================"
  uv self update 2>/dev/null || true
  uv tool upgrade --all 2>/dev/null || echo "Nenhuma tool instalada"

  echo ""
  echo "======================================"
  echo "  Node (Volta -> LTS)"
  echo "======================================"
  volta install node@lts

  echo ""
  echo "======================================"
  echo "  Go tools"
  echo "======================================"
  go install golang.org/x/tools/gopls@latest
  go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
  go install github.com/air-verse/air@latest

  echo ""
  echo "======================================"
  echo "  Oh My Zsh + plugins"
  echo "======================================"
  "$ZSH/tools/upgrade.sh" 2>/dev/null || omz update 2>/dev/null || true
  for plugin_dir in ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/*/; do
    if [[ -d "$plugin_dir/.git" ]]; then
      echo "  ~ $(basename $plugin_dir)"
      git -C "$plugin_dir" pull --quiet
    fi
  done

  echo ""
  echo "======================================"
  echo "  Atuin"
  echo "======================================"
  atuin self update 2>/dev/null || echo "atuin: atualizar via brew"

  echo ""
  echo "======================================"
  echo "  Tudo atualizado!"
  echo "======================================"
  echo ""
  echo "Versoes atuais:"
  echo "  Python : $(python --version 2>&1)"
  echo "  Node   : $(node --version 2>&1)"
  echo "  Yarn   : $(yarn --version 2>&1)"
  echo "  Go     : $(go version 2>&1 | awk '{print $3}')"
  echo "  Brew   : $(brew --version | head -1)"
  echo "  uv     : $(uv --version 2>&1)"
  echo "  Ruff   : $(ruff --version 2>&1)"
}

# ============================================================
# INICIALIZACOES
# ============================================================
[[ -d $PYENV_ROOT/bin ]] && eval "$(pyenv init - zsh)"
eval "$(uv generate-shell-completion zsh)"
eval "$(ruff generate-shell-completion zsh)"
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# Docker completions
fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit
compinit

# Atuin (historico inteligente)
eval "$(atuin init zsh)"

# fzf keybindings
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# p10k (descomentar se usar em vez do Starship)
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
```

---

## 6. Referencia rapida

### Gerenciadores de versao

| Linguagem | Gerenciador | Comando | Observacao |
|-----------|-------------|---------|------------|
| Python | **pyenv** | `pyenv install 3.12.8` / `pyenv global 3.12.8` | Compila do source |
| Python | **uv** (alt) | `uv python install 3.12` | Binarios pre-compilados |
| Node | **Volta** | `volta install node@22` | Pin via `package.json` |
| Go | **Homebrew** | `brew install go` | `GOTOOLCHAIN` resolve versoes via `go.mod` |

### Linters & Formatters

| Linguagem | Ferramenta | Lint | Format |
|-----------|-----------|------|--------|
| Python | **Ruff** | sim | sim |
| JS/TS | **Biome** | sim | sim |
| Go | **golangci-lint** | sim | nao |
| Go | **gofmt** | nao | sim (built-in) |

### Ferramentas CLI instaladas

| Comando | Substitui | Descricao |
|---------|-----------|-----------|
| `eza` | `ls` | ls com icones e git status |
| `bat` | `cat` | cat com syntax highlighting |
| `rg` | `grep` | grep ultrarrapido |
| `fd` | `find` | find moderno |
| `fzf` | — | fuzzy finder (Ctrl+R, Ctrl+T, Alt+C) |
| `zoxide` | `cd` | cd inteligente |
| `dust` | `du` | du visual |
| `procs` | `ps` | ps moderno |
| `btm` | `htop` | monitor de sistema |
| `delta` | `diff` | diff bonito no git |
| `difft` | `diff` | diff semantico |
| `tldr` | `man` | man pages simplificados |
| `jq` / `yq` | — | JSON / YAML processor |
| `httpie` | `curl` | HTTP client amigavel |
| `atuin` | history | historico de shell inteligente |
