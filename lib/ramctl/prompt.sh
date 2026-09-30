#!/data/data/com.termux/files/usr/bin/bash

ramctl_interactive_shell() {
    clear
    echo -e "${C_BOLD}${C_CYAN}=== RAMCTL Interactive Shell ===${C_RESET}"
    echo -e "${C_GRAY}Ketik ${C_YELLOW}/${C_GRAY} untuk melihat opsi perintah, atau ${C_RED}/exit${C_GRAY} untuk keluar.${C_RESET}\n"

    while true; do
        read -e -p "ramctl > " input
        
        # History expansion
        history -s "$input" 2>/dev/null || true

        case "$input" in
            /)
                echo -e "\n${C_BOLD}--- Rekomendasi Perintah (Slash Commands) ---${C_RESET}"
                echo -e "  ${C_GREEN}/status${C_RESET}       - Lihat penggunaan RAM & Swap"
                echo -e "  ${C_GREEN}/monitor${C_RESET}      - Buka TUI Realtime Live Monitor"
                echo -e "  ${C_GREEN}/storage${C_RESET}      - Cek kesehatan UFS / eMMC Life"
                echo -e "  ${C_GREEN}/clean${C_RESET}        - Bersihkan RAM Drop Caches (Root)"
                echo -e "  ${C_GREEN}/kill-heavy${C_RESET}   - Scan & hentikan aplikasi pemakan RAM terbesar"
                echo -e "  ${C_GREEN}/sweep${C_RESET}        - Bersihkan junk & cache file aplikasi"
                echo -e "  ${C_GREEN}/help${C_RESET}         - Tampilkan bantuan"
                echo -e "  ${C_RED}/exit${C_RESET}         - Keluar dari shell interaktif\n"
                ;;
            /status|status)
                ramctl_fetch_memory
                echo -e "\n${C_BOLD}--- Status Memori ---${C_RESET}"
                echo -e "RAM Usage : ${C_GREEN}${MEM_USED} KB${C_RESET} / ${MEM_TOTAL} KB (${MEM_USAGE_PCT}%)"
                echo -e "RAM Avail : ${C_CYAN}${MEM_AVAIL} KB${C_RESET}"
                echo -e "Swap Usage: ${SWAP_USED} KB / ${SWAP_TOTAL} KB (${SWAP_PCT}%)\n"
                ;;
            /monitor|monitor)
                ramctl_tui_live
                clear
                ;;
            /storage|storage)
                echo ""
                ramctl_fetch_storage_health
                echo ""
                ;;
            /clean|clean)
                ramctl_check_root
                echo 3 > /proc/sys/vm/drop_caches
                echo -e "${C_GREEN}✓ Cache RAM berhasil dibersihkan!${C_RESET}\n"
                ;;
            /kill-heavy)
                echo -e "\n${C_BOLD}--- Top 5 Proses Pemakan RAM ---${C_RESET}"
                ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6
                echo ""
                ;;
            /sweep)
                ramctl_check_root
                echo -e "${C_YELLOW}Cleaning app cache & system logs...${C_RESET}"
                rm -rf /data/local/tmp/* 2>/dev/null || true
                echo -e "${C_GREEN}✓ Junk cleaned successfully!${C_RESET}\n"
                ;;
            /help|help)
                echo ""
                ramctl_show_help
                echo ""
                ;;
            /exit|exit|quit|q)
                echo -e "${C_GRAY}Bye!${C_RESET}"
                break
                ;;
            "")
                ;;
            *)
                echo -e "${C_RED}Perintah '${input}' kagak ada bro! Ketik '/' buat daftar perintah.${C_RESET}\n"
                ;;
        esac
    done
}
