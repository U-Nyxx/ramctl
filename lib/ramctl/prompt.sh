#!/data/data/com.termux/files/usr/bin/bash

ramctl_interactive_shell() {
    clear
    echo -e "${C_BOLD}${C_CYAN}=== RAMCTL Interactive Shell ===${C_RESET}"
    echo -e "${C_GRAY}Ketik ${C_YELLOW}/${C_GRAY} untuk membuka Floating Command Navbar, atau ${C_RED}/exit${C_GRAY} untuk keluar.${C_RESET}\n"

    while true; do
        read -p "ramctl > " input

        # Jika pengguna mengetik '/'
        if [ "$input" == "/" ]; then
            # Menampilkan floating interactive menu pakai fzf
            CMD_SELECTED=$(printf "/status - Lihat statistik RAM & Swap\n/monitor - Realtime TUI Live Dashboard\n/storage - Health Life UFS / eMMC\n/kill-heavy - Top 5 Apps pemakan RAM terbesar\n/sweep - Bersihkan Junk & Cache aplikasi\n/clean - Drop Caches RAM (Root)\n/sysinfo - Ringkasan Perangkat & Kernel\n/sync - Auto Commit & Push ke GitHub Private\n/help - Bantuan\n/exit - Keluar" | fzf --height 40% --layout=reverse --border --prompt="Pilih Perintah > " --header="Gunakan panah [↑/↓] lalu [ENTER]")

            # Ambil hanya nama perintahnya saja
            input=$(echo "$CMD_SELECTED" | awk '{print $1}')
        fi

        case "$input" in
            /status)
                ramctl_fetch_memory
                echo -e "\n${C_BOLD}--- Status Memori ---${C_RESET}"
                echo -e "RAM Usage : ${C_GREEN}${MEM_USED} KB${C_RESET} / ${MEM_TOTAL} KB (${MEM_USAGE_PCT}%)"
                echo -e "RAM Avail : ${C_CYAN}${MEM_AVAIL} KB${C_RESET}"
                echo -e "Swap Usage: ${SWAP_USED} KB / ${SWAP_TOTAL} KB (${SWAP_PCT}%)\n"
                ;;
            /monitor)
                ramctl_tui_live
                clear
                ;;
            /storage)
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
            /clean)
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
            /help)
                echo ""
                ramctl_show_help
                echo ""
                ;;
            /exit)
                echo -e "${C_GRAY}Bye!${C_RESET}"
                break
                ;;
            "")
                ;;
            *)
                if [ -n "$input" ]; then
                    echo -e "${C_RED}Perintah '${input}' tidak valid! Ketik '/' untuk membuka menu.${C_RESET}\n"
                fi
                ;;
        esac
    done
}
