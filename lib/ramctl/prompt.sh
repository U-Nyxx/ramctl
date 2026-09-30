#!/data/data/com.termux/files/usr/bin/bash

ramctl_interactive_shell() {
    clear
    
    # Custom Pet Art / Header Banner (Bisa kamu ganti art Petdex di sini)
    echo -e "${C_CYAN}"
    echo "   /\_/\   "
    echo "  ( o.o )  RAMCTL PRO MAX TUI v1.2.0"
    echo "   > ^ <   Status: Active & Optimized"
    echo -e "${C_RESET}"
    echo -e "${C_GRAY}Ketik ${C_YELLOW}/${C_GRAY} lalu tekan Enter untuk membuka Floating Menu Navbar.${C_RESET}\n"

    while true; do
        printf "${C_BOLD}${C_GREEN}ramctl${C_RESET} ${C_CYAN}❯${C_RESET} "
        read -r input

        if [[ "$input" == /* ]]; then
            CMD_SELECTED=$(printf "/status   | [User] Cek statistik detail RAM & Swap\n/top-apps | [User] Top 10 Apps pemakan RAM terbesar\n/storage  | [Root] Cek kondisi kesehatan UFS/eMMC\n/clean    | [Root] Paksa Kernel bersihkan cache RAM\n/sweep    | [Root] Bersihkan junk, dalvik-cache, & temp log\n/sysinfo  | [User] Ringkasan hardware, kernel, & uptime\n/sync     | [User] Custom Sync ke GitHub Private\n/help     | [User] Bantuan lengkap\n/exit     | [User] Keluar" | fzf \
                --height 45% \
                --layout=reverse \
                --border=rounded \
                --delimiter=' \| ' \
                --with-nth=1 \
                --query="$input" \
                --prompt="⚡ Select Command ❯ " \
                --pointer="➜" \
                --color="bg+:-1,fg+:bright-white,prompt:cyan,pointer:green,border:magenta,header:yellow" \
                --header="───────[ NAVIGASI: ↑/↓ | PILIH: ENTER | BATAL: ESC ]───────" \
                --preview='echo -e "\n\033[1;33m📌 Deskripsi:\033[0m\n{2}"' \
                --preview-window=right:45%:wrap)

            if [ -n "$CMD_SELECTED" ]; then
                input=$(echo "$CMD_SELECTED" | awk '{print $1}')
            else
                echo ""
                continue
            fi
        fi

        case "$input" in
            /status)
                ramctl_fetch_memory
                echo -e "\n${C_BOLD}${C_CYAN}─── Status RAM & Swap ───${C_RESET}"
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
                read -p "$(echo -e ${C_YELLOW}"Masukkan PID (Tekan Enter untuk lewati): "${C_RESET})" target_pid
                if [ -n "$target_pid" ]; then
                    ramctl_run_as_root "kill -9 $target_pid 2>/dev/null || true"
                    echo -e "${C_GREEN}✓ Aplikasi PID $target_pid berhasil di-kill!${C_RESET}\n"
                else
                    echo ""
                fi
                ;;
            /storage)
                echo ""
                ramctl_run_as_root "for node in /sys/class/scsi_host/host*/device/ufs_health_descriptor/life_time_estimation_a /sys/devices/platform/soc/*.ufs/health_descriptor/life_time_estimation_a /sys/block/mmcblk0/device/life_time; do if [ -f \"\$node\" ]; then echo \"Health Indicator A: \$(cat \$node 2>/dev/null)\"; break; fi; done"
                echo ""
                ;;
            /clean)
                echo -e "${C_YELLOW}Clearing RAM Drop Caches...${C_RESET}"
                ramctl_run_as_root "echo 3 > /proc/sys/vm/drop_caches"
                echo -e "${C_GREEN}✓ Cache RAM berhasil dibersihkan via Root!${C_RESET}\n"
                ;;
            /sweep)
                echo -e "${C_YELLOW}Membersihkan cache aplikasi & log...${C_RESET}"
                ramctl_run_as_root "rm -rf /data/local/tmp/* /sdcard/Android/data/*/cache/* 2>/dev/null || true"
                echo -e "${C_GREEN}✓ File sampah berhasil dibersihkan!${C_RESET}\n"
                ;;
            /sysinfo)
                echo -e "\n${C_BOLD}${C_CYAN}─── System Info ───${C_RESET}"
                echo -e "OS/Kernel : $(uname -sr)"
                echo -e "Uptime    : $(uptime -p 2>/dev/null || uptime)"
                echo -e "Device    : $(getprop ro.product.model 2>/dev/null || echo 'Android Device')\n"
                ;;
            /sync)
                echo -e "\n${C_BOLD}${C_CYAN}⚙️  RAMCTL AUTO-SYNC ENGINE${C_RESET}"
                echo -e "${C_GRAY}───────────────────────────────────────${C_RESET}"
                
                read -p "$(echo -e ${C_YELLOW}"Target File/Folder [Tekan Enter untuk Semua (.)]: "${C_RESET})" target_path
                [ -z "$target_path" ] && target_path="."

                read -p "$(echo -e ${C_YELLOW}"Pesan Commit [Tekan Enter untuk Default]: "${C_RESET})" custom_msg
                [ -z "$custom_msg" ] && custom_msg="update: routine maintenance ($target_path)"

                echo -e "\n${C_CYAN}[1/3] Reinstalling lokal...${C_RESET}"
                cd ~/ramctl 2>/dev/null || true
                ./install.sh >/dev/null 2>&1

                echo -e "${C_CYAN}[2/3] Staging & Commit target ('$target_path')...${C_RESET}"
                git add "$target_path"
                git commit -m "$custom_msg"

                echo -e "${C_CYAN}[3/3] Pushing ke GitHub Private...${C_RESET}"
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
                    echo -e "${C_RED}Perintah '${input}' tidak dikenal! Ketik '/' untuk membuka menu Navbar.${C_RESET}\n"
                fi
                ;;
        esac
    done
}
