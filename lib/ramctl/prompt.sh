#!/data/data/com.termux/files/usr/bin/bash

PET_CONFIG_DIR="$HOME/.config/ramctl"
PET_CONFIG_FILE="$PET_CONFIG_DIR/pet.conf"

ramctl_get_saved_pet() {
    if [ -f "$PET_CONFIG_FILE" ]; then
        cat "$PET_CONFIG_FILE"
    else
        echo "cat"
    fi
}

ramctl_save_pet() {
    mkdir -p "$PET_CONFIG_DIR"
    echo "$1" > "$PET_CONFIG_FILE"
}

ramctl_render_pet() {
    local mode="$1"
    local frame="${2:-0}"
    
    case "$mode" in
        prabowo)
            if [ "$frame" -eq 0 ]; then
                echo -e "${C_CYAN}   /\\___/\\   \n  (  o.o  )  [ GENERAL CAT - PRABOWO ]\n   (   \"   )  BOOSTER Engine v2.0\n    \\_^_/    Status: High Performance${C_RESET}"
            else
                echo -e "${C_CYAN}   /\\___/\\   \n  (  -.-  )  [ GENERAL CAT - PRABOWO ]\n   (   =   )  BOOSTER Engine v2.0\n    \\_^_/    Status: High Performance${C_RESET}"
            fi
            ;;
        petdex)
            if [ "$frame" -eq 0 ]; then
                echo -e "${C_MAGENTA}   /\\_/\\  \n  (  v.v )  [ PETDEX DEV CUSTOM ]\n  /  |  \\   BOOSTER Engine v2.0\n  (__|__)   Status: Animated Active${C_RESET}"
            else
                echo -e "${C_MAGENTA}   /\\_/\\  \n  (  o.o )  [ PETDEX DEV CUSTOM ]\n  /  |  \\   BOOSTER Engine v2.0\n  (__|__)   Status: Animated Active${C_RESET}"
            fi
            ;;
        cat|*)
            if [ "$frame" -eq 0 ]; then
                echo -e "${C_YELLOW}   /\\_/\\   \n  ( o.o )  BOOSTER ENGINE v2.0\n   > ^ <   Status: Active & Optimized${C_RESET}"
            else
                echo -e "${C_YELLOW}   /\\_/\\   \n  ( -.- )  BOOSTER ENGINE v2.0\n   > ^ <   Status: Active & Optimized${C_RESET}"
            fi
            ;;
    esac
}

ramctl_live_status_dashboard() {
    clear
    tput civis
    local active_pet
    active_pet=$(ramctl_get_saved_pet)
    
    # Sinyal Ctrl+C dikembalikan aman ke prompt utama
    trap 'tput cnorm; echo -e "\n${C_GRAY}[Dibatalkan via Ctrl+C]${C_RESET}\n"; return' INT

    local frame=0
    echo -e "${C_GRAY}Tekan ${C_YELLOW}Ctrl+C${C_GRAY} untuk kembali ke prompt BOOSTER.${C_RESET}\n"

    while true; do
        tput cup 2 0
        ramctl_fetch_memory
        ramctl_render_pet "$active_pet" "$frame"
        
        echo -e "\n${C_BOLD}${C_CYAN}─── BOOSTER LIVE MEMORY DASHBOARD ───${C_RESET}"
        
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
    trap '' INT  # Abaikan Ctrl+C di shell utama agar tidak langsung keluar tools
    
    local current_pet
    current_pet=$(ramctl_get_saved_pet)
    ramctl_render_pet "$current_pet" 0
    echo -e "${C_GRAY}Tekan ${C_YELLOW}/${C_GRAY} untuk membuka Floating Navbar instan.${C_RESET}\n"

    local commands=("/status" "/top-apps" "/storage" "/clean" "/sweep" "/sysinfo" "/pet" "/sync" "/help" "/exit")

    while true; do
        printf "${C_BOLD}${C_GREEN}booster${C_RESET} ${C_CYAN}❯${C_RESET} "
        
        local input=""
        local ghost=""

        while true; do
            IFS= read -r -s -n 1 char

            if [ "$char" == "/" ] && [ -z "$input" ]; then
                echo "/"
                CMD_SELECTED=$(printf "/status   | Live Dashboard Statistik RAM, Swap, & Animasi\n/top-apps | Analisis Top 10 User Apps pemakan RAM\n/storage  | Evaluasi Hardware Life UFS/eMMC (Root)\n/clean    | Force Kernel Release Cache RAM (Root)\n/sweep    | Sapu bersih Junk & Cache aplikasi (Root)\n/sysinfo  | Informasi Ringkas OS, Kernel, & Device\n/pet      | Custom Ganti Pet Maskot Permanen\n/sync     | Custom Git Sync ke Private Repository\n/help     | Bantuan Penggunaan\n/exit     | Keluar dari Tools BOOSTER" | fzf \
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
                ramctl_live_status_dashboard
                clear
                current_pet=$(ramctl_get_saved_pet)
                ramctl_render_pet "$current_pet" 0
                echo ""
                ;;
            /top-apps)
                echo ""
                (
                    trap 'echo -e "\n${C_GRAY}[Dibatalkan via Ctrl+C]${C_RESET}\n"; return' INT
                    ramctl_top_user_apps
                    echo -e "\n${C_GRAY}Ingin menghentikan salah satu aplikasi di atas?${C_RESET}"
                    read -p "$(echo -e ${C_YELLOW}"Masukkan PID (Kosongkan jika tidak): "${C_RESET})" target_pid
                    if [ -n "$target_pid" ]; then
                        ramctl_run_as_root "kill -9 $target_pid 2>/dev/null || true"
                        echo -e "${C_GREEN}✓ Proses PID $target_pid berhasil dihentikan!${C_RESET}\n"
                    fi
                )
                ;;
            /storage)
                echo ""
                (
                    trap 'echo -e "\n${C_GRAY}[Dibatalkan via Ctrl+C]${C_RESET}\n"; return' INT
                    ramctl_exec_storage_health
                )
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
                echo -e "\n${C_BOLD}${C_CYAN}--- Custom Pet Selector (Persistent) ---${C_RESET}"
                read -p "$(echo -e ${C_YELLOW}"Pilih Maskot Permanen (cat / prabowo / petdex): "${C_RESET})" pet_choice
                if [ -n "$pet_choice" ]; then
                    ramctl_save_pet "$pet_choice"
                    clear
                    ramctl_render_pet "$pet_choice" 0
                    echo -e "\n${C_GREEN}✓ Maskot '$pet_choice' berhasil disimpan secara permanen!${C_RESET}\n"
                fi
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
                trap - INT
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
