#!/data/data/com.termux/files/usr/bin/bash

ramctl_interactive_shell() {
    clear
    echo -e "${C_BOLD}${C_CYAN}=== RAMCTL Interactive Shell ===${C_RESET}"
    echo -e "${C_GRAY}Tekan tombol ${C_YELLOW}/${C_GRAY} untuk langsung membuka menu, atau ketik perintah manual.${C_RESET}\n"

    while true; do
        printf "ramctl > "
        input=""
        
        while true; do
            # Baca per 1 karakter langsung tanpa nunggu enter
            IFS= read -r -n 1 char
            
            # Jika karakter yang diketik adalah '/'
            if [ "$char" == "/" ]; then
                echo "/"
                CMD_SELECTED=$(printf "/status - Lihat statistik RAM & Swap\n/monitor - Realtime TUI Live Dashboard\n/storage - Health Life UFS / eMMC (Auto Root)\n/kill-heavy - Top 5 Apps pemakan RAM terbesar\n/sweep - Bersihkan Junk & Cache aplikasi (Auto Root)\n/clean - Drop Caches RAM (Auto Root)\n/sysinfo - Ringkasan Perangkat & Kernel\n/sync - Auto Commit & Push ke GitHub Private\n/help - Bantuan\n/exit - Keluar" | fzf --height 40% --layout=reverse --border --prompt="Pilih Perintah > " --header="Gunakan panah [↑/↓] lalu [ENTER]")
                input=$(echo "$CMD_SELECTED" | awk '{print $1}')
                break
            fi

            # Jika menekan Enter
            if [ -z "$char" ]; then
                echo ""
                break
            fi

            # Jika menekan Backspace
            if [ "$char" == $'\177' ] || [ "$char" == $'\8' ]; then
                if [ -n "$input" ]; then
                    input="${input%?}"
                    printf "\b \b"
                fi
                continue
            fi

            # Karakter biasa
            input="${input}${char}"
            printf "%s" "$char"
        done

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
                ramctl_run_as_root "ramctl_fetch_storage_health"
                echo ""
                ;;
            /kill-heavy)
                echo -e "\n${C_BOLD}--- Top 5 Proses Pemakan RAM ---${C_RESET}"
                ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6
                echo ""
                ;;
            /sweep)
                echo -e "${C_YELLOW}Membersihkan cache aplikasi & log sistem...${C_RESET}"
                ramctl_run_as_root "rm -rf /data/local/tmp/* /sdcard/Android/data/*/cache/* 2>/dev/null || true"
                echo -e "${C_GREEN}✓ Junk berhasil dibersihkan via Root!${C_RESET}\n"
                ;;
            /clean)
                echo -e "${C_YELLOW}Clearing RAM Drop Caches...${C_RESET}"
                ramctl_run_as_root "echo 3 > /proc/sys/vm/drop_caches"
                echo -e "${C_GREEN}✓ Cache RAM berhasil dibersihkan via Root!${C_RESET}\n"
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
                git commit -m "feat: instant triggered slash command menu"
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
                    echo -e "${C_RED}Perintah '${input}' tidak valid! Tekan '/' untuk membuka menu.${C_RESET}\n"
                fi
                ;;
        esac
    done
}
