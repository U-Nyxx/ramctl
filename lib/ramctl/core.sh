#!/data/data/com.termux/files/usr/bin/bash

RAMCTL_NAME="ramctl"
RAMCTL_VERSION="1.0.0"

# ANSI Colors
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_RED='\033[31m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_CYAN='\033[36m'
C_GRAY='\033[90m'

# Auto-Elevate ke Root kalau belum di mode root
ramctl_run_as_root() {
    if [ "$(id -u)" -ne 0 ]; then
        # Eksekusi ulang perintah via su (KSUNext auto-grant)
        su -c "$1"
    else
        eval "$1"
    fi
}

ramctl_show_help() {
    echo -e "${C_BOLD}${C_CYAN}RAMCTL - Professional RAM & Storage Manager${C_RESET} v${RAMCTL_VERSION}"
    echo -e "${C_GRAY}Penggunaan:${C_RESET} ram [subcommand] [option]\n"
    echo -e "${C_BOLD}Perintah Utama:${C_RESET}"
    echo -e "  ${C_GREEN}status${C_RESET}      Cek statistik penggunaan RAM & Swap"
    echo -e "  ${C_GREEN}monitor${C_RESET}     Tampilan dashboard real-time TUI"
    echo -e "  ${C_GREEN}storage${C_RESET}     Mengecek kondisi kesehatan UFS/eMMC"
    echo -e "  ${C_GREEN}clean${C_RESET}       Bersihkan cache RAM (Auto Root)"
    echo -e "  ${C_GREEN}sweep${C_RESET}       Membersihkan file sampah/junk (Auto Root)\n"
    echo -e "${C_BOLD}Option:${C_RESET}"
    echo -e "  -h, --help     Tampilkan bantuan"
    echo -e "  -v, --version  Tampilkan versi aplikasi\n"
}

ramctl_unknown_cmd() {
    echo -e "${C_RED}Error: Perintah '${1}' tidak dikenal!${C_RESET}\n"
    echo -e "Ketik '${C_YELLOW}ram${C_RESET}' untuk membuka Interactive Floating Menu."
    exit 1
}
