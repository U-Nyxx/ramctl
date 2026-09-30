#!/data/data/com.termux/files/usr/bin/bash

ramctl_get_mem() {
    awk -v key="$1" '$1 == key {print $2; exit}' /proc/meminfo
}

ramctl_fetch_memory() {
    MEM_TOTAL=$(ramctl_get_mem "MemTotal:")
    MEM_FREE=$(ramctl_get_mem "MemFree:")
    MEM_AVAIL=$(ramctl_get_mem "MemAvailable:")
    SWAP_TOTAL=$(ramctl_get_mem "SwapTotal:")
    SWAP_FREE=$(ramctl_get_mem "SwapFree:")

    MEM_USED=$((MEM_TOTAL - MEM_AVAIL))
    MEM_USAGE_PCT=$((MEM_USED * 100 / MEM_TOTAL))
    
    SWAP_USED=$((SWAP_TOTAL - SWAP_FREE))
    if [ "$SWAP_TOTAL" -gt 0 ]; then
        SWAP_PCT=$((SWAP_USED * 100 / SWAP_TOTAL))
    else
        SWAP_PCT=0
    fi
}

ramctl_fetch_storage_health() {
    echo -e "${C_BOLD}--- Deteksi Storage Status ---${C_RESET}"
    UFS_PATH=""
    for p in /sys/devices/platform/soc/*.ufshc /sys/class/scsi_host/host*/device; do
        if [ -d "$p" ]; then
            UFS_PATH="$p"
            break
        fi
    done

    if [ -n "$UFS_PATH" ]; then
        echo -e "Tipe Storage : ${C_GREEN}UFS (Universal Flash Storage)${C_RESET}"
        if [ -f "$UFS_PATH/health_descriptor/life_time_estimation_a" ]; then
            LIFE_A=$(cat "$UFS_PATH/health_descriptor/life_time_estimation_a" 2>/dev/null)
            LIFE_B=$(cat "$UFS_PATH/health_descriptor/life_time_estimation_b" 2>/dev/null)
            echo -e "Health Life A : ${C_YELLOW}${LIFE_A:-N/A}${C_RESET} (0x01 = 0-10% Wear)"
            echo -e "Health Life B : ${C_YELLOW}${LIFE_B:-N/A}${C_RESET} (0x01 = 0-10% Wear)"
        else
            echo -e "Health Info   : ${C_GRAY}Akses Root dibutuhkan untuk membaca descriptor.${C_RESET}"
        fi
    else
        echo -e "Tipe Storage : ${C_CYAN}eMMC / Standard Storage${C_RESET}"
    fi
}
