#!/data/data/com.termux/files/usr/bin/bash

ramctl_render_pet() {
    local mode="${1:-cat}"
    local frame="${2:-0}"
    case "$mode" in
        prabowo)
            if [ "$frame" -eq 0 ]; then
                echo -e "${C_CYAN}   /\\___/\\   \n  (  o.o  )  [ GENERAL CAT - PRABOWO EDITION ]\n   (   \"   )  BOOSTER Engine v2.0\n    \\_^_/    Status: Active & Live${C_RESET}"
            else
                echo -e "${C_CYAN}   /\\___/\\   \n  (  -.-  )  [ GENERAL CAT - PRABOWO EDITION ]\n   (   =   )  BOOSTER Engine v2.0\n    \\_^_/    Status: Active & Live${C_RESET}"
            fi
            ;;
        petdex)
            echo -e "${C_MAGENTA}   /\\_/\\  \n  (  v.v )  [ PETDEX DEV CUSTOM ]\n  /  |  \\   BOOSTER Engine v2.0\n  (__|__)   Powered by Petdex Custom Art${C_RESET}"
            ;;
        cat|*)
            if [ "$frame" -eq 0 ]; then
                echo -e "${C_YELLOW}   /\\_/\\   \n  ( o.o )  BOOSTER ENGINE v2.0\n   > ^ <   Status: Active & Live${C_RESET}"
            else
                echo -e "${C_YELLOW}   /\\_/\\   \n  ( -.- )  BOOSTER ENGINE v2.0\n   > ^ <   Status: Active & Live${C_RESET}"
            fi
            ;;
    esac
}

# Animasi Dashboard Realtime
ramctl_tui_live_monitor() {
    clear
    tput civis # Sembunyikan kursor
    trap 'tput cnorm; clear; return' INT
    
    local frame=0
    echo -e "${C_GRAY}Tekan ${C_RED}Ctrl+C${C_GRAY} untuk keluar dari Live Monitor.${C_RESET}\n"

    while true; do
        tput cup 2 0
        ramctl_fetch_memory
        ramctl_render_pet "cat" "$frame"
        
        echo -e "\n${C_BOLD}${C_CYAN}─── REALTIME MONITORING DASHBOARD ───${C_RESET}"
        
        # Progress bar RAM
        local bar=""
        local filled=$((MEM_USAGE_PCT / 5))
        for ((i=0; i<20; i++)); do
            if [ $i -lt $filled ]; then bar="${bar}█"; else bar="${bar}░"; fi
        done
        
        echo -e "RAM Usage  : [${C_GREEN}${bar}${C_RESET}] ${MEM_USAGE_PCT}% (${MEM_USED} / ${MEM_TOTAL} KB)"
        echo -e "RAM Avail  : ${C_CYAN}${MEM_AVAIL} KB${C_RESET}"
        echo -e "Swap Usage : ${SWAP_USED} / ${SWAP_TOTAL} KB (${SWAP_PCT}%)"
        echo -e "Uptime     : $(uptime -p 2>/dev/null || uptime)"
        
        frame=$(((frame + 1) % 2))
        sleep 1
    done
    tput cnorm
}

ramctl_interactive_shell() {
    clear
    ramctl_render_pet "cat" 0
    echo -e "${C_GRAY}Tekan ${C_YELLOW}/${C_GRAY} untuk membuka Floating Navbar instan, atau ketik perintah.${C_RESET}\n"

    local commands=("/status" "/monitor" "/top-apps" "/storage" "/clean" "/sweep" "/sysinfo" "/pet" "/sync" "/help" "/exit")

    while true; do
        printf "${C_BOLD}${C_GREEN}booster${C_RESET} ${C_CYAN}❯${C_RESET} "
        
        local input=""
        local ghost=""

        while true; do
            IFS= read -r -s -n 1 char

            if [ "$char" == "/" ] && [ -z "$input" ]; then
                echo "/"
                CMD_SELECTED=$(printf "/status   | Detail statistik RAM & Swap\n/monitor  | TUI Dashboard Monitor Realtime Animasi\n/top-apps | Analisis Top 10 User Apps pemakan RAM\n/storage  | Evaluasi Hardware Life UFS/eMMC (Root)\n/clean    | Force Kernel Release Cache RAM (Root)\n/sweep    | Sapu bersih Junk & Cache aplikasi (Root)\n/sysinfo  | Informasi Ringkas OS, Kernel, & Device\n/pet      | Ganti Maskot Pet (cat / prabowo / petdex)\n/sync     | Custom Git Sync ke Private Repository\n/help     | Bantuan Penggunaan\n/exit     | Keluar Shell" | fzf \
                    --height 50% \
                    --layout=reverse \
                    --border=rounded \
                    --delimiter=' \| ' \
                    --with-nth=1 \
                    --prompt="⚡ BOOSTER Cmd ❯ " \
                    --pointer="➜" \
                    --color="bg+:-1,fg+:bright-white,prompt:cyan,pointer:green,border:magenta,header:yellow" \
                    --header="───────[ NAVIGASI: ↑/↓ | ENTER: Pilih | ESC: Batal ]───────" \
                    --preview='echo -e "\n\033[1;33m📌 Deskripsi:\033[0m\n{2}"' \
                    --preview-window=right:45%:wrap)

                if [ -n "$CMD_SELECTED" ]; then
                    input=$(echo "$CMD_SELECTED" | awk '{print $1}')
                fi
                break
            fi

            if [ -z "$char" ]; then
                echo ""
                break
            fi

            if [ "$char" == $'\177' ] || [ "$char" == $'\8' ]; then
                if [ -n "$input" ]; then
                    input="${input%?}"
                    printf "\r\033[K${C_BOLD}${C_GREEN}booster${C_RESET} ${C_CYAN}❯${C_RESET} %s" "$input"
                fi
                continue
            fi

            if [ "$char" == $'\t' ]; then
                if [ -n "$ghost" ]; then
                    input="${input}${ghost}"
                    printf "\r\033[K${C_BOLD}${C_GREEN}booster${C_RESET} ${C_CYAN}❯${C_RESET} %s" "$input"
                    ghost=""
                fi
                continue
            fi

            input="${input}${char}"

            ghost=""
            if [ -n "$input" ]; then
                for cmd in "${commands[@]}"; do
                    if [[ "$cmd" == "$input"* ]]; then
                        ghost="${cmd#$input}"
                        break
                    fi
                done
            fi

            printf "\r\033[K${C_BOLD}${C_GREEN}booster${C_RESET} ${C_CYAN}❯${C_RESET} %s${C_GRAY}%s${C_RESET}" "$input" "$ghost"
            if [ -n "$ghost" ]; then
                printf "\033[%dD" "${#ghost}"
            fi
        done

        case "$input" in
            /status)
                ramctl_fetch_memory
                echo -e "\n${C_BOLD}${C_CYAN}─── BOOSTER Memory Metrics ───${C_RESET}"
                echo -e "RAM Total   : ${MEM_TOTAL} KB"
                echo -e "RAM Used    : ${C_GREEN}${MEM_USED} KB${C_RESET} (${MEM_USAGE_PCT}%)"
                echo -e "RAM Avail   : ${C_CYAN}${MEM_AVAIL} KB${C_RESET}"
                echo -e "Swap Total  : ${SWAP_TOTAL} KB"
                echo -e "Swap Used   : ${SWAP_USED} KB (${SWAP_PCT}%)\n"
                ;;
            /monitor)
                ramctl_tui_live_monitor
                clear
                ramctl_render_pet "cat" 0
                echo ""
                ;;
            /top-apps)
                echo ""
                ramctl_top_user_apps
                echo -e "\n${C_GRAY}Ingin menghentikan salah satu aplikasi di atas?${C_RESET}"
                read -p "$(echo -e ${C_YELLOW}"Masukkan PID (Kosongkan jika tidak): "${C_RESET})" target_pid
                if [ -n "$target_pid" ]; then
                    ramctl_run_as_root "kill -9 $target_pid 2>/dev/null || true"
                    echo -e "${C_GREEN}✓ Proses PID $target_pid berhasil dihentikan!${C_RESET}\n"
                else
                    echo ""
                fi
                ;;
            /storage)
                echo ""
                ramctl_exec_storage_health
                echo ""
                ;;
            /clean)
                echo -e "${C_YELLOW}Clearing RAM Drop Caches...${C_RESET}"
                ramctl_run_as_root "echo 3 > /proc/sys/vm/drop_caches"
                echo -e "${C_GREEN}✓ Cache RAM berhasil dibersihkan via Root!${C_RESET}\n"
                ;;
            /sweep)
                echo -e "${C_YELLOW}Membersihkan Junk File & App Cache...${C_RESET}"
                ramctl_run_as_root "rm -rf /data/local/tmp/* /sdcard/Android/data/*/cache/* 2>/dev/null || true"
                echo -e "${C_GREEN}✓ Junk berhasil dibersihkan via Root!${C_RESET}\n"
                ;;
            /sysinfo)
                echo -e "\n${C_BOLD}${C_CYAN}─── System Specs ───${C_RESET}"
                echo -e "OS/Kernel : $(uname -sr)"
                echo -e "Uptime    : $(uptime -p 2>/dev/null || uptime)"
                echo -e "Device    : $(getprop ro.product.model 2>/dev/null || echo 'Android Device')\n"
                ;;
            /pet)
                echo -e "\n${C_BOLD}${C_CYAN}--- Custom Pet Art Selector ---${C_RESET}"
                read -p "$(echo -e ${C_YELLOW}"Pilih Maskot (cat / prabowo / petdex): "${C_RESET})" pet_choice
                clear
                ramctl_render_pet "$pet_choice" 0
                echo ""
                ;;
            /sync)
                echo -e "\n${C_BOLD}${C_CYAN}⚙️  BOOSTER AUTO-SYNC ENGINE${C_RESET}"
                echo -e "${C_GRAY}───────────────────────────────────────${C_RESET}"
                
                read -p "$(echo -e ${C_YELLOW}"Target File/Folder [Enter untuk Semua (.)]: "${C_RESET})" target_path
                [ -z "$target_path" ] && target_path="."

                read -p "$(echo -e ${C_YELLOW}"Pesan Commit [Enter untuk Default]: "${C_RESET})" custom_msg
                [ -z "$custom_msg" ] && custom_msg="update: routine maintenance ($target_path)"

                echo -e "\n${C_CYAN}[1/3] Reinstalling lokal...${C_RESET}"
                cd ~/ramctl 2>/dev/null || true
                ./install.sh >/dev/null 2>&1

                echo -e "${C_CYAN}[2/3] Staging & Commit ('$target_path')...${C_RESET}"
                git add "$target_path"
                git commit -m "$custom_msg"

                echo -e "${C_CYAN}[3/3] Pushing to GitHub Private...${C_RESET}"
                git push origin main

                echo -e "\n${C_GREEN}✓ SYNC BERHASIL!${C_RESET}"
                echo -e "  Target  : $target_path"
                echo -e "  Message : \"$custom_msg\"\n"
                ;;
            /help)
                echo ""
                ramctl_show_help
                echo ""
                ;;
            /exit)
                echo -e "${C_GRAY}Sampai jumpa!${C_RESET}"
                break
                ;;
            "")
                ;;
            *)
                if [ -n "$input" ]; then
                    echo -e "${C_RED}Perintah '${input}' tidak valid! Tekan '/' untuk membuka Floating Navbar.${C_RESET}\n"
                fi
                ;;
        esac
    done
}
