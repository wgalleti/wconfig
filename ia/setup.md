# IA — Editores e Ferramentas com IA

> Pos-instalacao via [`setup.sh`](setup.sh). Aqui estao apenas as configuracoes manuais.
>
> **Aliases usados:** `bi` = `brew install` | `bs` = `brew search` | `bup` = atualiza tudo (definidos em [mac/setup.md](../mac/setup.md))

## 1. Executar o script

```bash
chmod +x setup.sh
./setup.sh
```

| Ferramenta | Instalacao manual | Tipo |
|------------|------------------|------|
| Cursor | `bi --cask cursor` | VS Code fork com IA |
| Antigravity | `bi --cask antigravity` | VS Code fork do Google com Gemini |
| Claude Code | `bi claude-code` | CLI agentico no terminal |

Tudo via Homebrew. Atualizar com `bup` ou individualmente:

```bash
brew upgrade --cask cursor antigravity
brew upgrade claude-code
```

---

## 2. Cursor

### 2.1 Login

Abra o Cursor e faca login: **Settings → Sign In**.

### 2.2 Configuracoes recomendadas

Settings (Cmd + ,):

| Configuracao | Valor | Motivo |
|-------------|-------|--------|
| Cursor Tab | **Enabled** | Autocomplete com IA |
| Copilot++ | **Enabled** | Sugestoes multi-linha |
| Privacy Mode | **Enabled** | Nao treinar com seu codigo |
| Default Model | **claude-sonnet-4-5** | Melhor custo/beneficio |

### 2.3 Extensoes recomendadas

Fork do VS Code — mesmas extensoes:

```bash
cursor --install-extension esbenp.prettier-vscode
cursor --install-extension biomejs.biome
cursor --install-extension charliermarsh.ruff
cursor --install-extension ms-python.python
cursor --install-extension golang.go
cursor --install-extension bradlc.vscode-tailwindcss
cursor --install-extension eamodio.gitlens
cursor --install-extension catppuccin.catppuccin-vsc
cursor --install-extension catppuccin.catppuccin-vsc-icons
cursor --install-extension editorconfig.editorconfig
```

### 2.4 Settings JSON

Cmd + Shift + P → "Open User Settings (JSON)":

```json
{
  "editor.fontSize": 14,
  "editor.fontFamily": "JetBrainsMono Nerd Font, monospace",
  "editor.fontLigatures": true,
  "editor.minimap.enabled": false,
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "biomejs.biome",
  "editor.rulers": [80, 120],
  "editor.bracketPairColorization.enabled": true,
  "editor.guides.bracketPairs": true,
  "editor.stickyScroll.enabled": true,
  "workbench.colorTheme": "Catppuccin Mocha",
  "workbench.iconTheme": "catppuccin-mocha",
  "terminal.integrated.fontFamily": "JetBrainsMono Nerd Font",
  "terminal.integrated.fontSize": 13,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff"
  },
  "[go]": {
    "editor.defaultFormatter": "golang.go"
  }
}
```

### 2.5 Atalhos do Cursor

| Atalho | Acao |
|--------|------|
| Cmd K | Editar codigo com IA (inline) |
| Cmd L | Abrir chat lateral |
| Cmd I | Composer (agente multi-arquivo) |
| Cmd Shift I | Composer em tela cheia |
| Tab | Aceitar sugestao do Cursor Tab |
| Esc | Rejeitar sugestao |

---

## 3. Google Antigravity

### 3.1 Login

Abra o Antigravity e faca login com sua conta Google.

### 3.2 Configuracoes recomendadas

Fork do VS Code focado em agentes com Gemini. Settings (Cmd + ,):

| Configuracao | Valor | Motivo |
|-------------|-------|--------|
| Agent Model | **Gemini 3 Pro** | Modelo mais capaz |
| Privacy | **Do not train** | Privacidade do codigo |
| Theme | **Catppuccin Mocha** | Consistencia visual |

### 3.3 Extensoes

Mesmas do Cursor. Instalar via CLI:

```bash
antigravity --install-extension esbenp.prettier-vscode
antigravity --install-extension biomejs.biome
antigravity --install-extension charliermarsh.ruff
antigravity --install-extension ms-python.python
antigravity --install-extension golang.go
antigravity --install-extension catppuccin.catppuccin-vsc
antigravity --install-extension catppuccin.catppuccin-vsc-icons
antigravity --install-extension editorconfig.editorconfig
```

### 3.4 Settings JSON

Mesma base do Cursor (Cmd + Shift + P → "Open User Settings JSON"):

```json
{
  "editor.fontSize": 14,
  "editor.fontFamily": "JetBrainsMono Nerd Font, monospace",
  "editor.fontLigatures": true,
  "editor.minimap.enabled": false,
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "biomejs.biome",
  "editor.rulers": [80, 120],
  "editor.bracketPairColorization.enabled": true,
  "editor.guides.bracketPairs": true,
  "editor.stickyScroll.enabled": true,
  "workbench.colorTheme": "Catppuccin Mocha",
  "workbench.iconTheme": "catppuccin-mocha",
  "terminal.integrated.fontFamily": "JetBrainsMono Nerd Font",
  "terminal.integrated.fontSize": 13,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff"
  },
  "[go]": {
    "editor.defaultFormatter": "golang.go"
  }
}
```

---

## 4. Claude Code

### 4.1 Autenticacao

```bash
# Primeira execucao — abre o browser para autenticar
claude
```

### 4.2 Configuracao

```bash
# Modelo padrao
claude config set model claude-sonnet-4-5

# Permitir ferramentas automaticamente
claude config set autoApprove edit,write,bash

# Tema
claude config set theme dark
```

### 4.3 Uso basico

```bash
# Iniciar no diretorio do projeto
cd meu-projeto
claude

# Comando direto (sem modo interativo)
claude "explique o que esse projeto faz"

# Continuar ultima conversa
claude --continue

# Modo headless (scripts/CI)
claude -p "adicione testes para utils.py"
```

### 4.4 CLAUDE.md

Crie um `CLAUDE.md` na raiz de cada projeto para dar contexto:

```markdown
# Instrucoes para Claude Code

## Stack
- Python 3.12, Django 5, DRF
- PostgreSQL, Redis
- uv para gerenciamento de deps

## Convencoes
- Testes com pytest
- Lint com ruff
- Commits em portugues
```

### 4.5 Atualizacao

```bash
brew upgrade claude-code
```

---

## 5. Referencia rapida

### Comparativo

| | Cursor | Antigravity | Claude Code |
|--|--------|-------------|-------------|
| Tipo | IDE (VS Code fork) | IDE (VS Code fork) | CLI no terminal |
| IA | Multi-modelo | Gemini | Claude |
| Extensoes VS Code | sim | sim | n/a |
| Gratuito | Limitado | Preview gratuito | Com API key |
| Melhor para | Coding assistido | Agentes Google | Terminal/automacao |
| Instalacao | `bi --cask cursor` | `bi --cask antigravity` | `bi claude-code` |

### Atualizacao (tudo via brew)

```bash
# Tudo de uma vez
bup

# Individualmente
brew upgrade --cask cursor antigravity
brew upgrade claude-code
```
