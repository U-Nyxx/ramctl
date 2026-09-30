#!/data/data/com.termux/files/usr/bin/bash

RAMCTL_NAME="BOOSTER"
RAMCTL_VERSION="2.0.0"

C_RESET='\033[0m'
C_BOLD='\033[1m'
C_RED='\033[31m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_CYAN='\033[36m'
C_MAGENTA='\033[35m'
C_GRAY='\033[90m'

# Menjalankan perintah privileged via Root tanpa crash subshell
ramctl_run_as_root() {
    local cmd="$1"
    if [ "$(id -u)" -ne 0 ]; then
        su -c "$cmd"
    else
        eval "$cmd"
    fi
}

ramctl_show_help() {
    echo -e "${C_BOLD}${C_CYAN}BOOSTER Engine${C_RESET} v${RAMCTL_VERSION}"
    echo -e "${C_GRAY}Penggunaan:${C_RESET} ram [subcommand]\n"
    echo -e "${C_BOLD}Perintah Utama:${C_RESET}"
    echo -e "  ${C_GREEN}status${C_RESET}      Cek statistik detail RAM & Swap"
    echo -e "  ${C_GREEN}storage${C_RESET}     Evaluasi kesehatan hardware UFS / eMMC"
    echo -e "  ${C_GREEN}clean${C_RESET}       Drop caches RAM via Kernel Root\n"
}

ramctl_unknown_cmd() {
    echo -e "${C_RED}Error: Perintah '${1}' tidak valid!${C_RESET}"
    echo -e "Ketik '${C_YELLOW}ram${C_RESET}' untuk masuk ke BOOSTER TUI Shell."
    exit 1
}
