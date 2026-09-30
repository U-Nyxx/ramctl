#!/data/data/com.termux/files/usr/bin/bash

# Auto-complete setup buat slash commands
ramctl_setup_autocomplete() {
    local commands="/status /monitor /storage /clean /kill-heavy /sweep /sysinfo /sync /help /exit"
    complete -W "$commands" ram 2>/dev/null || true
}

ramctl_interactive_shell() {
    clear
    ramctl_setup_autocomplete
    echo -e "${C_BOLD}${C_CYAN}=== RAMCTL Interactive Shell ===${C_RESET}"
    echo -e "${C_GRAY}Ketik ${C_YELLOW}/${C_GRAY} lalu tekan [TAB] atau [ENTER] buat liat perintah.${C_RESET}\n"

    while true; do
        read -e -p "ramctl > " input
        history -s "$input" 2>/dev/null || true

        case "$input" in
            /)
                echo -e "\n${C_BOLD}--- Rekomendasi Slash Commands ---${C_RESET}"
                echo -e "  ${C_GREEN}/status${C_RESET}       - Lihat statistik RAM & Swap"
                echo -e "  ${C_GREEN}/monitor${C_RESET}      - Live TUI Dashboard"
                echo -e "  ${C_GREEN}/storage${C_RESET}      - Health Life UFS / eMMC"
                echo -e "  ${C_GREEN}/kill-heavy${C_RESET}   - Top 5 Apps pemakan RAM terbanyak"
                echo -e "  ${C_GREEN}/sweep${C_RESET}        - Bersihkan Junk & Cache aplikasi"
                echo -e "  ${C_GREEN}/clean${C_RESET}        - Drop Caches RAM (Root)"
                echo -e "  ${C_GREEN}/sysinfo${C_RESET}      - Ringkasan Perangkat & Kernel"
                echo -e "  ${C_GREEN}/sync${C_RESET}         - Auto Commit & Push ke GitHub Private"
                echo -e "  ${C_RED}/exit${C_RESET}         - Keluar\n"
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
            /clean|clean)
                ramctl_check_root
                echo 3 > /proc/sys/vm/drop_caches
                echo -e "${C_GREEN}✓ Cache RAM berhasil dibersihkan!${C_RESET}\n"
                ;;
            /sysinfo)
                echo -e "\n${C_BOLD}--- System Info ---${C_RESET}"
                echo -e "OS/Kernel : $(uname -sr)"
                echo -e "Uptime    : $(uptime -p 2>/dev/null || uptime)"
                echo -e "Device    : $(getprop ro.product.model 2>/dev/null || echo 'Android Device')\n"
                ;;
            /sync)
                echo -e "\n${C_YELLOW}Syncing ke GitHub Private...${C_RESET}"
                cd ~/ramctl 2>/dev/null || true
                ./install.sh >/dev/null 2>&1
                git add .
                git commit -m "auto-update via /sync"
                git push origin main
                echo -e "${C_GREEN}✓ Berhasil terinstall & ter-push ke GitHub!${C_RESET}\n"
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
                echo -e "${C_RED}Perintah '${input}' kagak ada bro! Ketik '/' buat liat opsi.${C_RESET}\n"
                ;;
        esac
    done
}
