#!/data/data/com.termux/files/usr/bin/bash

RAMCTL_NAME="ramctl"
RAMCTL_VERSION="1.1.0"

C_RESET='\033[0m'
C_BOLD='\033[1m'
C_RED='\033[31m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_CYAN='\033[36m'
C_GRAY='\033[90m'

# Auto-Elevate ke Root via su -c
ramctl_run_as_root() {
    if [ "$(id -u)" -ne 0 ]; then
        su -c "$1"
    else
        eval "$1"
    fi
}

ramctl_show_help() {
    echo -e "${C_BOLD}${C_CYAN}RAMCTL - Professional Android Optimization Tool${C_RESET} v${RAMCTL_VERSION}"
    echo -e "${C_GRAY}Penggunaan:${C_RESET} ram [subcommand]\n"
    echo -e "${C_BOLD}Perintah Utama:${C_RESET}"
    echo -e "  ${C_GREEN}status${C_RESET}      Cek statistik RAM & Swap"
    echo -e "  ${C_GREEN}storage${C_RESET}     Cek kesehatan UFS / eMMC (Root)"
    echo -e "  ${C_GREEN}clean${C_RESET}       Bersihkan cache RAM (Root)\n"
}

ramctl_unknown_cmd() {
    echo -e "${C_RED}Error: Perintah '${1}' tidak dikenal!${C_RESET}"
    echo -e "Ketik '${C_YELLOW}ram${C_RESET}' untuk membuka Interactive Shell."
    exit 1
}
