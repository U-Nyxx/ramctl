#!/data/data/com.termux/files/usr/bin/bash

ramctl_interactive_shell() {
    clear
    echo -e "${C_BOLD}${C_CYAN}=== RAMCTL Interactive Shell ===${C_RESET}"
    echo -e "${C_GRAY}Tekan tombol ${C_YELLOW}/${C_GRAY} untuk membuka Floating Command Navbar, atau ketik perintah.${C_RESET}\n"

    while true; do
        printf "ramctl > "
        input=""
        
        while true; do
            IFS= read -r -n 1 char
            
            if [ "$char" == "/" ]; then
                echo "/"
                
                CMD_SELECTED=$(printf "/status | [User] Cek penggunaan statistik RAM & Swap\n/monitor | [User] Dashboard monitor TUI realtime tanpa flicker\n/storage | [Root] Evaluasi kesehatan hardware UFS/eMMC Life\n/kill-heavy | [User] Cari & tampilkan 5 proses pemakan RAM terbesar\n/sweep | [Root] Sapu bersih cache app, dalvik, & temp log sistem\n/clean | [Root] Paksa Kernel melepas RAM cache (drop_caches)\n/sysinfo | [User] Informasi detail OS, Kernel, Uptime, & Perangkat\n/sync | [User] Re-install lokal & Custom Commit Push ke GitHub\n/help | [User] Tampilkan panduan lengkap penggunaan\n/exit | [User] Keluar dari shell interaktif" | fzf \
                    --height 45% \
                    --layout=reverse \
                    --border=rounded \
                    --delimiter=' \| ' \
                    --with-nth=1 \
                    --prompt="⚡ Select Cmd > " \
                    --header="[↑/↓] Navigasi  |  [ENTER] Pilih  |  [ESC] Batal" \
                    --preview='echo -e "\n\033[1;36mInformasi Perintah:\033[0m\n{2}\n\n\033[1;90mStatus Hak Akses:\033[0m Akses otomatis ditangani oleh KSUNext."' \
                    --preview-window=right:45%:wrap)

                input=$(echo "$CMD_SELECTED" | awk '{print $1}')
                break
            fi

            if [ -z "$char" ]; then
                echo ""
                break
            fi

            if [ "$char" == $'\177' ] || [ "$char" == $'\8' ]; then
                if [ -n "$input" ]; then
                    input="${input%?}"
                    printf "\b \b"
                fi
                continue
            fi

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
                echo -e "\n${C_BOLD}${C_CYAN}--- Custom Auto Sync Engine ---${C_RESET}"
                read -p "Masukkan pesan commit (Kosongkan jika ingin default): " custom_msg
                
                if [ -z "$custom_msg" ]; then
                    custom_msg="update: routine maintenance and code sync"
                fi

                echo -e "${C_YELLOW}1. Memperbarui instalasi lokal...${C_RESET}"
                cd ~/ramctl 2>/dev/null || true
                ./install.sh >/dev/null 2>&1

                echo -e "${C_YELLOW}2. Staging & Commit file...${C_RESET}"
                git add .
                git commit -m "$custom_msg"

                echo -e "${C_YELLOW}3. Push ke GitHub Private...${C_RESET}"
                git push origin main

                echo -e "${C_GREEN}✓ Selesai! Pesan commit: \"$custom_msg\"${C_RESET}\n"
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
