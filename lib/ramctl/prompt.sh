#!/data/data/com.termux/files/usr/bin/bash

ramctl_interactive_shell() {
    clear
    echo -e "${C_BOLD}${C_CYAN}┌────────────────────────────────────────────────────────┐${C_RESET}"
    echo -e "${C_BOLD}${C_CYAN}│${C_RESET}  ${C_BOLD}${C_YELLOW}⚡ RAMCTL INTERACTIVE SHELL${C_RESET} ${C_GRAY}v1.0.0 (Pro Max UI)${C_CYAN}    │${C_RESET}"
    echo -e "${C_BOLD}${C_CYAN}└────────────────────────────────────────────────────────┘${C_RESET}"
    echo -e "${C_GRAY}Tekan tombol ${C_YELLOW}/${C_GRAY} untuk membuka Floating Command Navbar.${C_RESET}\n"

    while true; do
        printf "${C_BOLD}${C_GREEN}ramctl${C_RESET} ${C_CYAN}❯${C_RESET} "
        input=""
        
        while true; do
            IFS= read -r -n 1 char
            
            if [ "$char" == "/" ]; then
                echo "/"
                
                # Floating FZF Pro Max Layout
                CMD_SELECTED=$(printf "/status   │ [User] Statistik detail RAM & Swap real-time\n/monitor  │ [User] Realtime Live Dashboard TUI (Flicker-Free)\n/storage  │ [Root] Cek kondisi kesehatan & umur UFS/eMMC\n/kill-heavy │ [User] Top 5 aplikasi pemakan RAM terbesar\n/sweep    │ [Root] Bersihkan junk, dalvik-cache, & temp log\n/clean    │ [Root] Paksa Kernel bersihkan drop_caches RAM\n/sysinfo  │ [User] Ringkasan hardware, kernel, & uptime\n/sync     │ [User] Custom Sync (Target File & Commit Msg)\n/help     │ [User] Panduan lengkap penggunaan tool\n/exit     │ [User] Keluar dari shell" | fzf \
                    --height 50% \
                    --layout=reverse \
                    --border=rounded \
                    --margin=1,2 \
                    --padding=0,1 \
                    --delimiter=' │ ' \
                    --with-nth=1 \
                    --prompt="⚡ Select Command ❯ " \
                    --pointer="➜" \
                    --color="bg+:-1,structure:magenta,fg+:bright-white,prompt:cyan,pointer:green" \
                    --header="───────────────[ NAVIGATION: ↑/↓ | SELECT: ENTER | EXIT: ESC ]───────────────" \
                    --preview='echo -e "\n\033[1;33m📌 Deskripsi Fitur:\033[0m\n{2}\n\n\033[1;36m🛡️ Status Akses:\033[0m Auto-elevation via KSUNext Root."' \
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
                echo -e "\n${C_BOLD}${C_CYAN}─── Status Memori ───${C_RESET}"
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
                echo -e "\n${C_BOLD}${C_CYAN}─── Top 5 Proses Pemakan RAM ───${C_RESET}"
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
                echo -e "\n${C_BOLD}${C_CYAN}─── System Info ───${C_RESET}"
                echo -e "OS/Kernel : $(uname -sr)"
                echo -e "Uptime    : $(uptime -p 2>/dev/null || uptime)"
                echo -e "Device    : $(getprop ro.product.model 2>/dev/null || echo 'Android Device')\n"
                ;;
            /sync)
                echo -e "\n${C_BOLD}${C_CYAN}⚙️  RAMCTL PRO MAX AUTO-SYNC ENGINE${C_RESET}"
                echo -e "${C_GRAY}───────────────────────────────────────${C_RESET}"
                
                # Custom Target File Selection
                read -p "$(echo -e ${C_YELLOW}"Target File/Folder [Tekan Enter untuk SEMUA (.): "${C_RESET})" target_path
                if [ -z "$target_path" ]; then
                    target_path="."
                fi

                # Custom Commit Message Selection
                read -p "$(echo -e ${C_YELLOW}"Pesan Commit [Tekan Enter untuk Default]: "${C_RESET})" custom_msg
                if [ -z "$custom_msg" ]; then
                    custom_msg="update: routine maintenance and sync ($target_path)"
                fi

                echo -e "\n${C_CYAN}[1/4] Rebuilding & Reinstalling lokal...${C_RESET}"
                cd ~/ramctl 2>/dev/null || true
                ./install.sh >/dev/null 2>&1

                echo -e "${C_CYAN}[2/4] Staging target: '${target_path}'...${C_RESET}"
                git add "$target_path"

                echo -e "${C_CYAN}[3/4] Creating commit...${C_RESET}"
                git commit -m "$custom_msg"

                echo -e "${C_CYAN}[4/4] Pushing to GitHub Private...${C_RESET}"
                git push origin main

                echo -e "\n${C_GREEN}✓ SYNC SUCCESSFUL!${C_RESET}"
                echo -e "  Target  : ${C_BOLD}$target_path${C_RESET}"
                echo -e "  Message : ${C_BOLD}\"$custom_msg\"${C_RESET}\n"
                ;;
            /help)
                echo ""
                ramctl_show_help
                echo ""
                ;;
            /exit)
                echo -e "${C_GRAY}Sampai jumpa bro!${C_RESET}"
                break
                ;;
            "")
                ;;
            *)
                if [ -n "$input" ]; then
                    echo -e "${C_RED}Perintah '${input}' tidak valid! Tekan '/' untuk membuka menu Pro Max.${C_RESET}\n"
                fi
                ;;
        esac
    done
}
