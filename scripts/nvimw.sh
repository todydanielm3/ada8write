#!/usr/bin/env bash
# nvimw.sh - Abre o NeoVim no livro ativo, com a configuracao de escrita.
#
#   ./scripts/nvimw.sh                 abre a pasta do livro ativo
#   ./scripts/nvimw.sh arquivo.txt     abre um arquivo
#
# O cwd do editor e sempre a raiz do livro ativo, para que os atalhos do
# init.lua (01_personagens/, 02_cenas/, ...) apontem para o livro certo.

set -uo pipefail
. "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

require_book

NVIM_CONFIG="${PLATFORM_ROOT}/.nvim"
[ -f "${NVIM_CONFIG}/init.lua" ] || die "Configuração do NeoVim não encontrada em .nvim/init.lua"

command -v nvim >/dev/null 2>&1 || die "NeoVim não encontrado. Instale com: brew install neovim"

export NVIM_APPNAME="book-nvim"
export BOOK_SLUG BOOK_ROOT BOOK_EXT

TARGET="${1:-}"

cd "$BOOK_ROOT" || die "Não consegui entrar em $BOOK_ROOT"

if [ -n "$TARGET" ]; then
    nvim -u "${NVIM_CONFIG}/init.lua" "$TARGET"
else
    nvim -u "${NVIM_CONFIG}/init.lua" "$BOOK_ROOT"
fi
