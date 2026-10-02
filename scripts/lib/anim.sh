#!/usr/bin/env bash
# lib/anim.sh - Animacao de abertura do menu.
#
# Ordem de preferencia:
#   1. GIF real renderizado no terminal (chafa, imgcat/iTerm2, kitty icat, viu)
#   2. Animacao ASCII (fallback universal)
#
# Desligue com BOOK_ANIMATION=0 no book.config ou exportando BOOK_NO_ANIM=1.

ANIM_GIF="${DIR_ASSETS:-$PROJECT_ROOT/assets}/intro.gif"

hide_cursor() { printf "\033[?25l"; }
show_cursor() { printf "\033[?25h"; }

anim_enabled() {
    [ -t 1 ] || return 1
    [ "${BOOK_NO_ANIM:-0}" = "1" ] && return 1
    [ "${BOOK_ANIMATION:-1}" = "1" ] || return 1
    return 0
}

# Detecta um renderizador de imagem disponivel no terminal.
# Force um especifico com BOOK_ANIM_PLAYER=chafa|imgcat|kitty|viu|ascii
anim_gif_player() {
    if [ -n "${BOOK_ANIM_PLAYER:-}" ] && [ "${BOOK_ANIM_PLAYER}" != "auto" ]; then
        [ "${BOOK_ANIM_PLAYER}" = "ascii" ] && { echo ""; return; }
        echo "${BOOK_ANIM_PLAYER}"
        return
    fi
    if [ -n "${ITERM_SESSION_ID:-}" ] && command -v imgcat >/dev/null 2>&1; then
        echo "imgcat"
    elif command -v chafa >/dev/null 2>&1; then
        echo "chafa"
    elif [ "${TERM:-}" = "xterm-kitty" ] && command -v kitty >/dev/null 2>&1; then
        echo "kitty"
    elif command -v viu >/dev/null 2>&1; then
        echo "viu"
    else
        echo ""
    fi
}

anim_play_gif() {
    local player="$1" cols w
    [ -f "$ANIM_GIF" ] || return 1
    cols=$(tput cols 2>/dev/null || echo 80)
    w=$(( cols - 8 ))
    [ "$w" -gt 76 ] && w=76
    [ "$w" -lt 40 ] && w=40
    case "$player" in
        chafa)  chafa --animate=on --duration=3 --clear --align=center \
                      --size="${w}x$(( w / 4 ))" "$ANIM_GIF" 2>/dev/null || return 1 ;;
        imgcat) printf "\033[2J\033[H\n\n"; imgcat "$ANIM_GIF" 2>/dev/null || return 1; sleep 3 ;;
        kitty)  kitty +kitten icat --align=center "$ANIM_GIF" 2>/dev/null || return 1; sleep 3 ;;
        viu)    viu -w "$w" "$ANIM_GIF" 2>/dev/null || return 1; sleep 1 ;;
        *)      return 1 ;;
    esac
    return 0
}

# Centraliza uma linha no terminal
anim_center() {
    local line="$1" width pad
    width=$(tput cols 2>/dev/null || echo 80)
    # Conta caracteres (nao bytes) para nao quebrar com acentos
    local len
    len=$(printf '%s' "$line" | wc -m | tr -d ' ')
    pad=$(( (width - len) / 2 ))
    [ "$pad" -lt 0 ] && pad=0
    printf "%*s%b\n" "$pad" "" "$line"
}

# Centraliza um texto aplicando estilo sem contar os codigos de escape
anim_center_styled() {
    local text="$1" pre="$2" suf="$3" width len pad
    len=$(printf '%s' "$text" | wc -m | tr -d ' ')
    width=$(tput cols 2>/dev/null || echo 80)
    pad=$(( (width - len) / 2 ))
    [ "$pad" -lt 0 ] && pad=0
    printf "%*s%b%s%b\n" "$pad" "" "$pre" "$text" "$suf"
}

# Efeito maquina de escrever
anim_typewriter() {
    local text="$1" delay="${2:-0.012}" i=1 len out=""
    local width pad
    len=$(printf '%s' "$text" | wc -m | tr -d ' ')
    width=$(tput cols 2>/dev/null || echo 80)
    pad=$(( (width - len) / 2 ))
    [ "$pad" -lt 0 ] && pad=0
    printf "%*s" "$pad" ""
    while [ "$i" -le "$len" ]; do
        out=$(printf '%s' "$text" | cut -c "$i")
        printf '%s' "$out"
        sleep "$delay"
        i=$(( i + 1 ))
    done
    printf "\n"
}

# Quadros ASCII: livro abrindo e paginas virando
anim_frame() {
    case "$1" in
        1) cat <<'EOF'
                          ____
                        .'    '.
                        |      |
                        |      |
                        '.____.'
EOF
        ;;
        2) cat <<'EOF'
                       _____________
                      /             \
                     |       |       |
                     |       |       |
                      \_____________/
EOF
        ;;
        3) cat <<'EOF'
                    _______________________
                   /\                      \
                  |  |   ___   ___   ___    |
                  |  |  |___| |___| |___|   |
                   \_|______________________|
EOF
        ;;
        4) cat <<'EOF'
                 ___________________________
                /\                          \
               |  |   ______   ______        |
               |  |  |______| |______|   ✒   |
                \_|_________________________|
EOF
        ;;
    esac
}

anim_ascii() {
    local frames="1 2 3 4 3 4" f line
    hide_cursor
    for f in $frames; do
        printf "\033[H\033[2J"
        printf "\n\n"
        local IFS=$'\n'
        for line in $(anim_frame "$f"); do
            anim_center "${CYAN}${line}${RESET}"
        done
        unset IFS
        printf "\n"
        anim_center "${DIM}carregando seu ateliê de escrita...${RESET}"
        sleep 0.12
    done
    printf "\033[H\033[2J\n\n"
    local IFS=$'\n'
    for line in $(anim_frame 4); do
        anim_center "${CYAN}${line}${RESET}"
    done
    unset IFS
    printf "\n"
    anim_typewriter "N E O V I M   ·   A T E L I Ê   D E   E S C R I T A" 0.010
    sleep 0.25
    show_cursor
}

anim_intro() {
    anim_enabled || return 0
    local player
    player=$(anim_gif_player)
    printf "\033[H\033[2J"
    if [ -n "$player" ] && anim_play_gif "$player"; then
        sleep 0.2
    else
        anim_ascii
    fi
    if [ -n "${BOOK_TITLE:-}" ]; then
        printf "\n"
        anim_center_styled " ${BOOK_TITLE} " "$HL" "$HL_END"
        sleep 0.7
    fi
    trap show_cursor EXIT
}

# Barra de progresso simples usada em operacoes longas
anim_progress() {
    local label="$1" total="${2:-20}" i=0
    printf "  %s " "$label"
    while [ "$i" -lt "$total" ]; do
        printf "${CYAN}▰${RESET}"
        sleep 0.02
        i=$(( i + 1 ))
    done
    printf " ${GREEN}pronto${RESET}\n"
}
