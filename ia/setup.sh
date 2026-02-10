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

ERRORS=0

step() {
  echo -e "\n${BLUE}══════════════════════════════════════${NC}"
  echo -e "  ${GREEN}$1${NC}"
  echo -e "${BLUE}══════════════════════════════════════${NC}\n"
}

info()  { echo -e "  ${YELLOW}→${NC} $1"; }
ok()    { echo -e "  ${GREEN}✔${NC} $1"; }
fail()  { echo -e "  ${RED}✘${NC} $1"; ERRORS=$((ERRORS + 1)); }

# ── Verificar Homebrew ─────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "Homebrew nao encontrado. Rode primeiro: mac/setup.sh"
  exit 1
fi

# ── 1. Cursor ──────────────────────────────────────────────
step "1/3 — Cursor"
if brew list --cask cursor &>/dev/null; then
  ok "Ja instalado"
else
  brew install --cask cursor || fail "Cursor: falha na instalacao"
fi

# ── 2. Google Antigravity ─────────────────────────────────
step "2/3 — Google Antigravity"
if brew list --cask antigravity &>/dev/null; then
  ok "Ja instalado"
else
  brew install --cask antigravity || fail "Antigravity: falha na instalacao"
fi

# ── 3. Claude Code ─────────────────────────────────────────
step "3/3 — Claude Code"
if command -v claude &>/dev/null; then
  ok "Ja instalado: $(claude --version 2>&1)"
else
  brew install claude-code || fail "Claude Code: falha na instalacao"
fi

# ── Done ───────────────────────────────────────────────────
echo ""
if [[ $ERRORS -gt 0 ]]; then
  step "Setup IA concluido com ${ERRORS} erro(s)"
  echo -e "  ${RED}Rode novamente para tentar os passos que falharam.${NC}"
else
  step "Setup IA completo!"
fi

echo ""
echo "Proximos passos:"
echo "  1. Cursor: abra e faca login (Settings -> Sign In)"
echo "  2. Antigravity: abra e faca login com conta Google"
echo "  3. Claude Code: rode 'claude' no terminal e autentique"
echo ""
echo "Veja ia/setup.md para configuracoes detalhadas."
