#!/usr/bin/env bash
# lib/common.sh - Funcoes e configuracoes compartilhadas por todos os scripts.
# Uso: source "$(dirname "$0")/lib/common.sh"

# --------------------------------------------------------------------------
# Raiz da plataforma, livro ativo e configuracao
# --------------------------------------------------------------------------
# A plataforma (scripts, templates, editor, docs) e compartilhada.
# Cada livro vive isolado em livros/<slug>/ com seus proprios textos,
# sua configuracao e sua memoria de IA.
BOOK_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLATFORM_ROOT="$(cd "${BOOK_LIB_DIR}/../.." && pwd)"
BOOKS_DIR="${PLATFORM_ROOT}/livros"
ACTIVE_BOOK_FILE="${PLATFORM_ROOT}/.livro-ativo"
export PLATFORM_ROOT BOOKS_DIR

# Overrides vindos do ambiente tem a maior precedencia (env > livro > global)
_env_BOOK_EXT="${BOOK_EXT:-}"
_env_BOOK_EDITOR="${BOOK_EDITOR:-}"
_env_BOOK_ANIMATION="${BOOK_ANIMATION:-}"
_env_BOOK_ANIM_PLAYER="${BOOK_ANIM_PLAYER:-}"
_env_BOOK_WORD_GOAL="${BOOK_WORD_GOAL:-}"

# Valores padrao (sobrescritos por book.config global e depois pelo do livro)
BOOK_EXT="txt"
BOOK_EMPTY_BY_DEFAULT=1
BOOK_TITLE="Meu Livro"
BOOK_AUTHOR="Autor"
BOOK_LANG="pt-BR"
BOOK_WORD_GOAL=80000
BOOK_EDITOR="nvim"
BOOK_ANIMATION=1

# 1) Padroes globais da plataforma
if [ -f "${PLATFORM_ROOT}/book.config" ]; then
    # shellcheck disable=SC1090
    . "${PLATFORM_ROOT}/book.config"
fi

# --------------------------------------------------------------------------
# Resolucao do livro ativo
# --------------------------------------------------------------------------
books_list() {
    [ -d "$BOOKS_DIR" ] || return 0
    find "$BOOKS_DIR" -maxdepth 1 -mindepth 1 -type d ! -name '.*' 2>/dev/null \
        | LC_ALL=C sort | while IFS= read -r d; do basename "$d"; done
}

books_count() { books_list | grep -c . | tr -d ' '; }

book_exists() { [ -n "${1:-}" ] && [ -d "${BOOKS_DIR}/$1" ]; }

# Titulo legivel de um livro (le o book.config dele)
book_title_of() {
    local slug="$1" cfg="${BOOKS_DIR}/$1/book.config" t=""
    if [ -f "$cfg" ]; then
        t=$(grep -m1 '^BOOK_TITLE=' "$cfg" | sed -e 's/^BOOK_TITLE=//' -e 's/^"//' -e 's/"$//')
    fi
    [ -n "$t" ] && printf '%s' "$t" || printf '%s' "$slug"
}

# Slug do livro ativo: variavel de ambiente > .livro-ativo > primeiro livro
active_book_slug() {
    local slug=""
    if [ -n "${BOOK_SLUG:-}" ]; then
        slug="$BOOK_SLUG"
    elif [ -f "$ACTIVE_BOOK_FILE" ]; then
        slug=$(head -1 "$ACTIVE_BOOK_FILE" | tr -d ' \t\n')
    fi
    if ! book_exists "$slug"; then
        slug=$(books_list | head -1)
    fi
    printf '%s' "$slug"
}

set_active_book() {
    local slug="$1"
    book_exists "$slug" || return 1
    printf '%s\n' "$slug" > "$ACTIVE_BOOK_FILE"
    # Mantem a sessao atual coerente com o novo livro
    BOOK_SLUG="$slug"
    export BOOK_SLUG
    return 0
}

BOOK_SLUG="$(active_book_slug)"
BOOK_ROOT="${BOOKS_DIR}/${BOOK_SLUG}"
export BOOK_SLUG BOOK_ROOT

# 2) Configuracao do livro ativo (sobrescreve a global)
if [ -n "$BOOK_SLUG" ] && [ -f "${BOOK_ROOT}/book.config" ]; then
    # shellcheck disable=SC1090
    . "${BOOK_ROOT}/book.config"
fi

# 3) Ambiente vence qualquer arquivo de configuracao
[ -n "$_env_BOOK_EXT" ]       && BOOK_EXT="$_env_BOOK_EXT"
[ -n "$_env_BOOK_EDITOR" ]    && BOOK_EDITOR="$_env_BOOK_EDITOR"
[ -n "$_env_BOOK_ANIMATION" ] && BOOK_ANIMATION="$_env_BOOK_ANIMATION"
[ -n "$_env_BOOK_ANIM_PLAYER" ] && BOOK_ANIM_PLAYER="$_env_BOOK_ANIM_PLAYER"
[ -n "$_env_BOOK_WORD_GOAL" ] && BOOK_WORD_GOAL="$_env_BOOK_WORD_GOAL"
unset _env_BOOK_EXT _env_BOOK_EDITOR _env_BOOK_ANIMATION _env_BOOK_ANIM_PLAYER _env_BOOK_WORD_GOAL

# Normaliza a extensao (aceita "txt" ou ".txt")
BOOK_EXT="${BOOK_EXT#.}"
[ -z "$BOOK_EXT" ] && BOOK_EXT="txt"

# PROJECT_ROOT = raiz do livro ativo (compatibilidade com scripts antigos)
PROJECT_ROOT="$BOOK_ROOT"
export PROJECT_ROOT

# Diretorios do livro ativo
DIR_NOTAS="${BOOK_ROOT}/00_notas"
DIR_PERSONAGENS="${BOOK_ROOT}/01_personagens"
DIR_CENAS="${BOOK_ROOT}/02_cenas"
DIR_CAPITULOS="${BOOK_ROOT}/03_capitulos"
DIR_ARQUIVO="${BOOK_ROOT}/90_arquivo"
DIR_BUILD="${BOOK_ROOT}/99_build"
DIR_BOOK_AI="${BOOK_ROOT}/.ai"

# Diretorios compartilhados da plataforma
DIR_TEMPLATES="${PLATFORM_ROOT}/templates"
DIR_SCRIPTS="${PLATFORM_ROOT}/scripts"
DIR_ASSETS="${PLATFORM_ROOT}/assets"
DIR_DOCS="${PLATFORM_ROOT}/docs"

# Variaveis lidas pelos scripts Python para isolar cada livro
export BOOK_PROJECT_ROOT="$BOOK_ROOT"
export BOOK_CACHE_DIR="${DIR_BOOK_AI}/cache"
export BOOK_PLATFORM_ROOT="$PLATFORM_ROOT"

# Extensoes reconhecidas como texto do livro
BOOK_TEXT_EXTS="txt md markdown"

# --------------------------------------------------------------------------
# Cores e estilos (desativados quando nao ha TTY ou NO_COLOR esta definido)
# --------------------------------------------------------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    RESET="\033[0m";    BOLD="\033[1m";    DIM="\033[2m"
    RED="\033[31m";     GREEN="\033[32m";  YELLOW="\033[33m"
    BLUE="\033[34m";    MAGENTA="\033[35m"; CYAN="\033[36m"
    WHITE="\033[37m";   GRAY="\033[90m"
    # Marca-texto: fundo amarelo com texto preto (destaque do livro ativo)
    HL="\033[1;30;48;5;220m"
    HL_SOFT="\033[1;30;48;5;229m"
    HL_END="\033[0m"
else
    RESET=""; BOLD=""; DIM=""
    RED=""; GREEN=""; YELLOW=""; BLUE=""; MAGENTA=""; CYAN=""; WHITE=""; GRAY=""
    HL=""; HL_SOFT=""; HL_END=""
fi

# highlight <texto> - devolve o texto com marca-texto e uma folga lateral
highlight() { printf "%b %s %b" "$HL" "$*" "$HL_END"; }

# --------------------------------------------------------------------------
# Saida padronizada
# --------------------------------------------------------------------------
msg_ok()    { printf "${GREEN}✓${RESET} %s\n" "$*"; }
msg_info()  { printf "${CYAN}•${RESET} %s\n" "$*"; }
msg_warn()  { printf "${YELLOW}!${RESET} %s\n" "$*"; }
msg_error() { printf "${RED}✗${RESET} %s\n" "$*" >&2; }
msg_step()  { printf "${BOLD}${BLUE}»${RESET} %s\n" "$*"; }

die() { msg_error "$*"; exit 1; }

pause() {
    printf "\n${DIM}Pressione Enter para continuar...${RESET}"
    read -r _
}

term_width() {
    local w
    w=$(tput cols 2>/dev/null) || w=80
    [ -z "$w" ] && w=80
    echo "$w"
}

# --------------------------------------------------------------------------
# Texto e nomes de arquivo
# --------------------------------------------------------------------------

# slugify "Confronto na Biblioteca" -> confronto-na-biblioteca
slugify() {
    printf '%s' "$*" \
        | tr '[:upper:]' '[:lower:]' \
        | iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null \
        | sed -e 's/[^a-z0-9]\{1,\}/-/g' -e 's/^-//' -e 's/-$//'
}

# titleize "confronto-na-biblioteca" -> "Confronto Na Biblioteca"
titleize() {
    printf '%s' "$*" | sed 's/[-_]/ /g' \
        | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1'
}

# Conta caracteres visiveis (acentos contam como 1)
str_len() { printf '%s' "$*" | wc -m | tr -d ' '; }

# pad_to <texto> <largura> - completa com espacos contando caracteres, nao bytes
pad_to() {
    local s="$1" w="$2" len diff
    len=$(str_len "$s")
    diff=$(( w - len ))
    [ "$diff" -lt 0 ] && diff=0
    printf '%s%*s' "$s" "$diff" ""
}

# fit_to <texto> <largura> - trunca com reticencias quando nao couber
fit_to() {
    local s="$1" w="$2" len
    len=$(str_len "$s")
    if [ "$len" -gt "$w" ]; then
        printf '%s…' "$(printf '%s' "$s" | cut -c1-$(( w - 1 )))"
    else
        pad_to "$s" "$w"
    fi
}

# trunc_to <texto> <largura> - trunca com reticencias, sem completar
trunc_to() {
    local s="$1" w="$2" len
    len=$(str_len "$s")
    if [ "$len" -gt "$w" ]; then
        printf '%s…' "$(printf '%s' "$s" | cut -c1-$(( w - 1 )))"
    else
        printf '%s' "$s"
    fi
}

# Lista arquivos de texto de um diretorio (txt/md), ignorando ocultos e backups
list_text_files() {
    local dir="$1"
    [ -d "$dir" ] || return 0
    find "$dir" -maxdepth 1 -type f \
        \( -name '*.txt' -o -name '*.md' -o -name '*.markdown' \) \
        ! -name '.*' ! -name '*.bak-*' 2>/dev/null | LC_ALL=C sort
}

count_text_files() {
    list_text_files "$1" | grep -c . | tr -d ' '
}

# Conta palavras de um diretorio inteiro
count_words_dir() {
    local dir="$1" total=0 n
    local IFS=$'\n'
    for f in $(list_text_files "$dir"); do
        n=$(wc -w < "$f" 2>/dev/null | tr -d ' ')
        total=$(( total + ${n:-0} ))
    done
    echo "$total"
}

count_words_project() {
    local total=0 d n
    for d in "$DIR_CAPITULOS" "$DIR_CENAS" "$DIR_PERSONAGENS" "$DIR_NOTAS"; do
        n=$(count_words_dir "$d")
        total=$(( total + ${n:-0} ))
    done
    echo "$total"
}

# --------------------------------------------------------------------------
# Criacao de arquivos
# --------------------------------------------------------------------------

# ensure_unique_path <caminho> -> ecoa um caminho livre (acrescenta -2, -3, ...)
ensure_unique_path() {
    local path="$1" base ext n=2
    [ -e "$path" ] || { echo "$path"; return 0; }
    ext="${path##*.}"
    base="${path%.*}"
    while [ -e "${base}-${n}.${ext}" ]; do
        n=$(( n + 1 ))
    done
    echo "${base}-${n}.${ext}"
}

# backup_file <arquivo>
backup_file() {
    local f="$1" b
    [ -f "$f" ] || return 0
    b="${f}.bak-$(date +%Y%m%d-%H%M%S)"
    cp "$f" "$b" && msg_info "Backup: $(basename "$b")"
}

# Encontra o template correspondente, qualquer que seja a extensao
find_template() {
    local name="$1" f
    for f in "${DIR_TEMPLATES}/${name}.${BOOK_EXT}" "${DIR_TEMPLATES}/${name}.txt" "${DIR_TEMPLATES}/${name}.md"; do
        [ -f "$f" ] && { echo "$f"; return 0; }
    done
    return 1
}

# Limpa um nome de arquivo informado pelo usuario preservando o estilo digitado
sanitize_name() {
    printf '%s' "$*" \
        | tr '/' '-' \
        | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' \
        | sed -e 's/\.\{1,\}$//'
}

# create_doc <diretorio> <nome-base> <template|""> <titulo>
# Cria o arquivo com a extensao padrao. Vazio por padrao; usa o template
# apenas quando USE_TEMPLATE=1. Ecoa o caminho criado em CREATED_PATH.
create_doc() {
    local dir="$1" base="$2" template_name="$3" title="$4"
    local target template

    mkdir -p "$dir"
    target="${dir}/${base}.${BOOK_EXT}"

    if [ -e "$target" ]; then
        if [ "${FORCE:-0}" = "1" ]; then
            backup_file "$target"
        else
            target=$(ensure_unique_path "$target")
            msg_warn "Já existia um arquivo com esse nome; criando $(basename "$target")"
        fi
    fi

    if [ "${USE_TEMPLATE:-0}" = "1" ] && [ -n "$template_name" ]; then
        if template=$(find_template "$template_name"); then
            cp "$template" "$target"
            local today
            today=$(date +%Y-%m-%d)
            LC_ALL=C sed -i '' \
                -e "s/YYYY-MM-DD/${today}/g" \
                -e "s/\[Título da Cena\]/${title}/g" \
                -e "s/\[Título\]/${title}/g" \
                -e "s/\[Nome\]/${title}/g" \
                "$target" 2>/dev/null || true
        else
            msg_warn "Template '${template_name}' não encontrado; criando arquivo vazio."
            : > "$target"
        fi
    else
        : > "$target"
    fi

    CREATED_PATH="$target"
    export CREATED_PATH
}

# --------------------------------------------------------------------------
# Livro ativo: exigencia e escrita de configuracao
# --------------------------------------------------------------------------

# Interrompe o script quando nenhum livro esta ativo
require_book() {
    if [ -z "${BOOK_SLUG:-}" ] || [ ! -d "${BOOK_ROOT:-}" ]; then
        msg_error "Nenhum livro ativo neste workspace."
        msg_info "Crie o primeiro com: ./scripts/new_book.sh \"Título do livro\""
        exit 1
    fi
}

# config_set <chave> <valor> [global]
# Sem o terceiro argumento grava no book.config do livro ativo.
config_set() {
    local key="$1" value="$2" scope="${3:-livro}" cfg

    if [ "$scope" = "global" ] || [ -z "${BOOK_SLUG:-}" ]; then
        cfg="${PLATFORM_ROOT}/book.config"
    else
        cfg="${BOOK_ROOT}/book.config"
    fi

    [ -f "$cfg" ] || : > "$cfg"

    if grep -q "^${key}=" "$cfg"; then
        LC_ALL=C sed -i '' "s|^${key}=.*|${key}=\"${value}\"|" "$cfg"
    else
        printf '%s="%s"\n' "$key" "$value" >> "$cfg"
    fi
}

# --------------------------------------------------------------------------
# Editor
# --------------------------------------------------------------------------
open_in_editor() {
    local target="$1"
    [ -n "$target" ] || return 0
    case "$BOOK_EDITOR" in
        nvim|vim)
            if command -v nvim >/dev/null 2>&1; then
                bash "${DIR_SCRIPTS}/nvimw.sh" "$target"
            elif command -v vim >/dev/null 2>&1; then
                vim "$target"
            else
                msg_warn "nvim/vim nao encontrados. Arquivo: $target"
            fi
            ;;
        code)
            if command -v code >/dev/null 2>&1; then
                code "$target"
            else
                msg_warn "VS Code (code) nao esta no PATH. Arquivo: $target"
            fi
            ;;
        *)
            if [ -n "${BOOK_EDITOR:-}" ] && command -v "$BOOK_EDITOR" >/dev/null 2>&1; then
                "$BOOK_EDITOR" "$target"
            elif [ -n "${EDITOR:-}" ]; then
                "$EDITOR" "$target"
            else
                msg_warn "Nenhum editor configurado. Arquivo: $target"
            fi
            ;;
    esac
}
