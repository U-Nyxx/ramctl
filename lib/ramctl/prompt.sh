#!/data/data/com.termux/files/usr/bin/bash

ramctl_render_pet() {
    local mode="${1:-cat}"
    case "$mode" in
        prabowo)
            echo -e "${C_CYAN}"
            echo "   /\_/\   "
            echo "  (  o.o  )  [ GENERAL CAT - PRABOWO EDITION ]"
            echo "   (   \"   )  BOOSTER Engine v2.0"
            echo "    \_^_/    Ready to Optimize!"
            echo -e "${C_RESET}"
            ;;
        petdex)
            echo -e "${C_MAGENTA}"
            echo "   /\_/\  "
            echo "  (  v.v )  [ PETDEX DEV CUSTOM ]"
            echo "  /  |  \   BOOSTER Engine v2.0"
            echo "  (__|__)   Powered by Petdex Custom GIF/Art"
            echo -e "${C_RESET}"
            ;;
        cat|*)
            echo -e "${C_YELLOW}"
            echo "   /\_/\   "
            echo "  ( o.o )  BOOSTER ENGINE v2.0"
            echo "   > ^ <   Status: Active & Optimized"
            echo -e "${C_RESET}"
            ;;
    esac
}

ramctl_interactive_shell() {
    clear
    ramctl_render_pet "cat"
    echo -e "${C_GRAY}Tekan ${C_YELLOW}/${C_GRAY} untuk membuka Floating Navbar instan, atau ketik perintah.${C_RESET}\n"

    local commands=("/status" "/top-apps" "/storage" "/clean" "/sweep" "/sysinfo" "/pet" "/sync" "/help" "/exit")

    while true; do
        printf "${C_BOLD}${C_GREEN}booster${C_RESET} ${C_CYAN}❯${C_RESET} "
        
        local input=""
        local ghost=""

        while true; do
            IFS= read -r -s -n 1 char

            # INSTANT TRIGGER /
            if [ "$char" == "/" ] && [ -z "$input" ]; then
                echo "/"
                CMD_SELECTED=$(printf "/status   | Detail statistik RAM & Swap\n/top-apps | Analisis Top 10 User Apps pemakan RAM\n/storage  | Evaluasi Hardware Life UFS/eMMC (Root)\n/clean    | Force Kernel Release Cache RAM (Root)\n/sweep    | Sapu bersih Junk & Cache aplikasi (Root)\n/sysinfo  | Informasi Ringkas OS, Kernel, & Device\n/pet      | Ganti Maskot Pet (cat / prabowo / petdex)\n/sync     | Custom Git Sync ke Private Repository\n/help     | Bantuan Penggunaan\n/exit     | Keluar Shell" | fzf \
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
                ramctl_render_pet "$pet_choice"
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
