#!/data/data/com.termux/files/usr/bin/bash

RAMCTL_NAME="ramctl"
RAMCTL_VERSION="1.0.0"

# ANSI Colors (Clean & Professional)
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_RED='\033[31m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_CYAN='\033[36m'
C_GRAY='\033[90m'

# Cek Akses Root
ramctl_check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${C_RED}Error: Fitur ini membutuhkan akses Root (su).${C_RESET}"
        exit 1
    fi
}

# Banner Bantuan
ramctl_show_help() {
    echo -e "${C_BOLD}${C_CYAN}RAMCTL - Professional RAM & Storage Manager${C_RESET} v${RAMCTL_VERSION}"
    echo -e "${C_GRAY}Penggunaan:${C_RESET} ram [subcommand] [option]\n"
    echo -e "${C_BOLD}Perintah Utama:${C_RESET}"
    echo -e "  ${C_GREEN}status${C_RESET}      Cek statistik penggunaan RAM & Swap"
    echo -e "  ${C_GREEN}monitor${C_RESET}     Tampilan dashboard real-time TUI"
    echo -e "  ${C_GREEN}storage${C_RESET}     Mengecek kondisi kesehatan UFS/eMMC"
    echo -e "  ${C_GREEN}clean${C_RESET}       Bersihkan cache RAM (Butuh Root)\n"
    echo -e "${C_BOLD}Option:${C_RESET}"
    echo -e "  -h, --help     Tampilkan bantuan"
    echo -e "  -v, --version  Tampilkan versi aplikasi\n"
    echo -e "${C_BOLD}Contoh:${C_RESET}"
    echo -e "  $ ram status"
    echo -e "  $ ram monitor"
    echo -e "  $ ram clean --drop-caches"
}

# Error Handler jika Perintah Salah
ramctl_unknown_cmd() {
    echo -e "${C_RED}Error: Perintah '${1}' tidak dikenal!${C_RESET}\n"
    echo -e "Maksud Anda salah satu dari ini?"
    echo -e "  ${C_CYAN}ram status${C_RESET}"
    echo -e "  ${C_CYAN}ram monitor${C_RESET}"
    echo -e "  ${C_CYAN}ram clean --drop-caches${C_RESET}\n"
    echo -e "Ketik '${C_YELLOW}ram --help${C_RESET}' untuk melihat daftar perintah."
    exit 1
}
