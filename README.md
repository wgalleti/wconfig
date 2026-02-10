# wconfig

Configuracoes pessoais de ambiente de desenvolvimento para **macOS Apple Silicon** (M1/M2/M3/M4).

> Scripts e paths assumem arquitetura arm64 com Homebrew em `/opt/homebrew`. Nao compativel com Intel.

## Quick Start (Mac formatado)

Abra o Terminal e cole:

```bash
xcode-select --install
```

Aguarde terminar, depois:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install git
git clone git@github.com:wgalleti/wconfig.git ~/wconfig
cd ~/wconfig/mac && chmod +x setup.sh && ./setup.sh
```

> Sem SSH key? Use: `git clone https://github.com/wgalleti/wconfig.git ~/wconfig`

Apos o setup base, rode as ferramentas de IA:

```bash
cd ~/wconfig/ia && chmod +x setup.sh && ./setup.sh
```

Depois siga as configuracoes manuais em cada `setup.md`.

## Estrutura

```
mac/
  setup.sh   # Base do macOS (idempotente)
  setup.md   # Configuracoes manuais pos-instalacao

ia/
  setup.sh   # Editores e ferramentas com IA (idempotente)
  setup.md   # Configuracoes manuais pos-instalacao
```

## O que inclui

### mac/

- **Terminal:** iTerm2, Zsh, Oh My Zsh, Starship
- **CLI tools:** eza, bat, ripgrep, fd, fzf, zoxide, delta, atuin, neovim
- **Python:** pyenv, uv, ruff, ipython
- **Node:** Volta, Bun, Biome, Yarn Berry, pnpm
- **Go:** gopls, delve, golangci-lint, air, swag, sqlc
- **Docker:** Docker Desktop, lazydocker, dive, ctop
- **Databases:** pgcli, mycli, litecli, mongosh, redis
- **Git:** delta, aliases, rebase workflow

### ia/

- **Cursor:** IDE com IA multi-modelo (brew)
- **Google Antigravity:** IDE agent-first com Gemini (brew)
- **Claude Code:** CLI agentico no terminal (brew)
