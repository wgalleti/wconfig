# wconfig

Configuracoes pessoais de ambiente de desenvolvimento.

## Estrutura

```
mac/
  setup.sh   # Script de instalacao (idempotente)
  setup.md   # Configuracoes manuais pos-instalacao
```

## Uso

### macOS

```bash
cd mac
chmod +x setup.sh
./setup.sh
```

Apos o script, siga as configuracoes manuais em [`mac/setup.md`](mac/setup.md).

## O que inclui

- **Terminal:** iTerm2, Zsh, Oh My Zsh, Starship
- **CLI tools:** eza, bat, ripgrep, fd, fzf, zoxide, delta, atuin, neovim
- **Python:** pyenv, uv, ruff, ipython
- **Node:** Volta, Bun, Biome, Yarn Berry, pnpm
- **Go:** gopls, delve, golangci-lint, air, swag, sqlc
- **Docker:** Docker Desktop, lazydocker, dive, ctop
- **Databases:** pgcli, mycli, litecli, mongosh, redis
- **Git:** delta, aliases, rebase workflow
