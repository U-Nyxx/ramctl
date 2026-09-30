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

ramctl_top_user_apps() {
    echo -e "${C_BOLD}${C_CYAN}─── Top Apps Pemakan RAM (User Apps Only) ───${C_RESET}\n"
    printf "%-8s %-12s %-10s %s\n" "PID" "USER" "RSS(KB)" "NAME"
    echo -e "${C_GRAY}──────────────────────────────────────────────────${C_RESET}"
    
    ps -A -o PID,USER,RSS,NAME 2>/dev/null | grep -E "u0_a[0-9]+" | sort -k3 -n -r | head -n 10 | while read -r pid user rss name; do
        printf "%-8s %-12s %-10s %s\n" "$pid" "$user" "$rss" "$name"
    done
}
