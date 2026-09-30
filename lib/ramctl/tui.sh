#!/data/data/com.termux/files/usr/bin/bash

ramctl_draw_line() {
    local left=$1
    local right=$2
    local width=$(tput cols 2>/dev/null || echo 80)
    local line=""
    for ((i=0; i<width-2; i++)); do line="${line}─"; done
    echo -e "${C_CYAN}${left}${line}${right}${C_RESET}"
}

ramctl_progress_bar() {
    local pct=$1
    local width=20
    local filled=$((pct * width / 100))
    local empty=$((width - filled))
    local bar=""

    for ((i=0; i<filled; i++)); do bar="${bar}█"; done
    for ((i=0; i<empty; i++)); do bar="${bar}░"; done

    if [ "$pct" -gt 85 ]; then
        echo -e "${C_RED}[${bar}] ${pct}%${C_RESET}"
    elif [ "$pct" -gt 60 ]; then
        echo -e "${C_YELLOW}[${bar}] ${pct}%${C_RESET}"
    else
        echo -e "${C_GREEN}[${bar}] ${pct}%${C_RESET}"
    fi
}

ramctl_tui_live() {
    clear
    trap 'printf "\033[?25h"; clear; exit 0' INT TERM EXIT
    printf '\033[?25l' # Sembunyikan kursor

    while true; do
        printf '\033[H' # Pindahkan kursor ke pojok kiri atas (tanpa flicker)
        ramctl_fetch_memory

        ramctl_draw_line "┌" "┐"
        echo -e "${C_CYAN}│${C_RESET} ${C_BOLD}RAMCTL REALTIME MONITOR${C_RESET} $(date +'%H:%M:%S')                           ${C_CYAN}│${C_RESET}"
        ramctl_draw_line "├" "┤"
        
        local ram_bar=$(ramctl_progress_bar "$MEM_USAGE_PCT")
        echo -e "${C_CYAN}│${C_RESET} ${C_BOLD}RAM Usage :${C_RESET} ${ram_bar}  (${MEM_USED} KB / ${MEM_TOTAL} KB) ${C_CYAN}│${C_RESET}"
        echo -e "${C_CYAN}│${C_RESET} ${C_GRAY}Available :${C_RESET} ${MEM_AVAIL} KB                                   ${C_CYAN}│${C_RESET}"
        
        ramctl_draw_line "├" "┤"
        
        local swap_bar=$(ramctl_progress_bar "$SWAP_PCT")
        echo -e "${C_CYAN}│${C_RESET} ${C_BOLD}SWAP Usage:${C_RESET} ${swap_bar}  (${SWAP_USED} KB / ${SWAP_TOTAL} KB)  ${C_CYAN}│${C_RESET}"
        
        ramctl_draw_line "└" "┘"
        echo -e "\n${C_GRAY}Tekan [Ctrl+C] untuk keluar.${C_RESET}"
        
        sleep 1.5
    done
}
