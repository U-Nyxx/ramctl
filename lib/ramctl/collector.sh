#!/data/data/com.termux/files/usr/bin/bash

ramctl_fetch_memory() {
    if [ -f /proc/meminfo ]; then
        MEM_TOTAL=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
        MEM_FREE=$(awk '/MemFree:/ {print $2}' /proc/meminfo)
        MEM_AVAIL=$(awk '/MemAvailable:/ {print $2}' /proc/meminfo)
        [ -z "$MEM_AVAIL" ] && MEM_AVAIL=$MEM_FREE
        
        MEM_USED=$((MEM_TOTAL - MEM_AVAIL))
        MEM_USAGE_PCT=$((MEM_USED * 100 / MEM_TOTAL))

        SWAP_TOTAL=$(awk '/SwapTotal:/ {print $2}' /proc/meminfo)
        SWAP_FREE=$(awk '/SwapFree:/ {print $2}' /proc/meminfo)
        
        if [ "$SWAP_TOTAL" -gt 0 ]; then
            SWAP_USED=$((SWAP_TOTAL - SWAP_FREE))
            SWAP_PCT=$((SWAP_USED * 100 / SWAP_TOTAL))
        else
            SWAP_USED=0
            SWAP_PCT=0
        fi
    fi
}

ramctl_exec_storage_health() {
    echo -e "${C_BOLD}${C_CYAN}┌────────────────────────────────────────────────────────┐${C_RESET}"
    echo -e "${C_BOLD}${C_CYAN}│  ⚡ HARDWARE STORAGE DIAGNOSTICS (UFS / eMMC)          │${C_RESET}"
    echo -e "${C_BOLD}${C_CYAN}└────────────────────────────────────────────────────────┘${C_RESET}"
    
    ramctl_run_as_root '
    found=0
    for node in /sys/class/scsi_host/host*/device/ufs_health_descriptor/life_time_estimation_a \
                /sys/devices/platform/soc/*.ufs/health_descriptor/life_time_estimation_a \
                /sys/class/ufs-host/ufs-host*/life_time_estimation_a \
                /sys/block/mmcblk0/device/life_time \
                /sys/block/sd*/device/life_time; do
        if [ -f "$node" ]; then
            found=1
            val_a=$(cat "$node" 2>/dev/null)
            node_b="${node%_a}_b"
            val_b=""
            [ -f "$node_b" ] && val_b=$(cat "$node_b" 2>/dev/null)
            echo -e "Health Life (A) : \033[1;32m${val_a:-N/A}\033[0m"
            [ -n "$val_b" ] && echo -e "Health Life (B) : \033[1;32m${val_b}\033[0m"
            break
        fi
    done
    
    if [ $found -eq 0 ]; then
        echo -e "\033[1;33m[!] Sysfs Direct Node Lifetime Bypass\033[0m"
        df -h /data 2>/dev/null | awk "NR==2{print \"Data Partition    : \"\$3\" / \"\$2\" (\033[1;36m\"\$5\"\033[0m Used)\"}"
    fi
    '
}

ramctl_top_user_apps() {
    echo -e "${C_BOLD}${C_CYAN}┌────────────────────────────────────────────────────────┐${C_RESET}"
    echo -e "${C_BOLD}${C_CYAN}│  📊 TOP 10 USER APPS (MEMORY CONSUMPTION)             │${C_RESET}"
    echo -e "${C_BOLD}${C_CYAN}└────────────────────────────────────────────────────────┘${C_RESET}\n"
    printf "%-8s %-12s %-10s %s\n" "PID" "USER" "RSS(KB)" "PACKAGE / COMMAND"
    echo -e "${C_GRAY}──────────────────────────────────────────────────────────${C_RESET}"
    
    ps -A -o PID,USER,RSS,NAME 2>/dev/null | grep -E "u0_a[0-9]+" | sort -k3 -n -r | head -n 10 | while read -r pid user rss name; do
        printf "%-8s %-12s %-10s %s\n" "$pid" "$user" "$rss" "$name"
    done
}
