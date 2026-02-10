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

# ── Verificar Homebrew ─────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "Homebrew nao encontrado. Rode primeiro: mac/setup.sh"
  exit 1
fi

# ── 1. Cursor ──────────────────────────────────────────────
step "1/3 — Cursor"
brew install --cask cursor 2>/dev/null || info "Cursor ja instalado"
info "$(brew info --cask cursor 2>/dev/null | head -1)"

# ── 2. Google Antigravity ─────────────────────────────────
step "2/3 — Google Antigravity"
brew install --cask antigravity 2>/dev/null || info "Antigravity ja instalado"
info "$(brew info --cask antigravity 2>/dev/null | head -1)"

# ── 3. Claude Code ─────────────────────────────────────────
step "3/3 — Claude Code"
brew install claude-code 2>/dev/null || info "Claude Code ja instalado"
info "$(brew info claude-code 2>/dev/null | head -1)"

# ── Done ───────────────────────────────────────────────────
step "Setup IA completo!"
echo ""
echo "Proximos passos:"
echo "  1. Cursor: abra e faca login (Settings → Sign In)"
echo "  2. Antigravity: abra e faca login com conta Google"
echo "  3. Claude Code: rode 'claude' no terminal e autentique"
echo ""
echo "Veja ia/setup.md para configuracoes detalhadas."
