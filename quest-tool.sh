#!/bin/bash
RED='\033[1;31m'
DARKRED='\033[0;31m'
NC='\033[0m'
MATRIX_COLORS=($RED $DARKRED)
ADB_PATH=$(command -v adb)
if [ -z "$ADB_PATH" ]; then
    echo -e "${RED}ADB not found. Install android-platform-tools and add adb to PATH.${NC}"
    exit 1
fi
matrix_rain() {
    duration=2
    end=$((SECONDS+duration))
    rows=$(tput lines)
    cols=$(tput cols)
    while [ $SECONDS -lt $end ]; do
        clear
        for ((r=0;r<rows;r++)); do
            line=""
            for ((c=0;c<cols;c++)); do
                char=$(( RANDOM % 10 ))
                color=${MATRIX_COLORS[$RANDOM % ${#MATRIX_COLORS[@]}]}
                line+="${color}$char${NC}"
            done
            echo -e "$line"
        done
        sleep 0.05
    done
    clear
}
ascii_banner() {
    clear
    echo -e "${RED}"
    echo "░██████╗░██╗░░░██╗███╗░░██╗██╗░░░░░░█████╗░░█████╗░██╗░░██╗███████╗██████╗░"
    echo "██╔════╝░██║░░░██║████╗░██║██║░░░░░██╔══██╗██╔══██╗██║░██╔╝██╔════╝██╔══██╗"
    echo "██║░░██╗░██║░░░██║██╔██╗██║██║░░░░░██║░░██║██║░░╚═╝█████═╝░█████╗░░██║░░██║"
    echo "██║░░╚██╗██║░░░██║██║╚████║██║░░░░░██║░░██║██║░░██╗██╔═██╗░██╔══╝░░██║░░██║"
    echo "╚██████╔╝╚██████╔╝██║░╚███║███████╗╚█████╔╝╚█████╔╝██║░╚██╗███████╗██████╔╝"
    echo "░╚═════╝░░╚═════╝░╚═╝░░╚══╝╚══════╝░╚════╝░░╚════╝░╚═╝░░╚═╝╚══════╝╚═════╝░"
    echo -e "${NC}"
    echo -e "${RED}Quest Terminal Tool - By Silent${NC}"
    echo "-------------------------------------------"
}
choose_fps() {
    echo -e "${RED}Choose FPS:${NC}"
    echo "1) 72"
    echo "2) 80"
    echo "3) 90"
    echo "4) 120"
    echo "5) Custom (1-200)"
    read -p "Select option (1-5): " choice
    case $choice in
        1) FPS=72 ;;
        2) FPS=80 ;;
        3) FPS=90 ;;
        4) FPS=120 ;;
        5) 
            read -p "Enter custom FPS (1-200): " custom
            if ! [[ $custom =~ ^[0-9]+$ ]] || [ $custom -lt 1 ] || [ $custom -gt 200 ]; then
                echo -e "${RED}Invalid input! Using 90 FPS.${NC}"
                FPS=90
            else
                FPS=$custom
            fi
            ;;
        *) 
            echo -e "${RED}Invalid choice! Using 90 FPS.${NC}"
            FPS=90 ;;
    esac
}
choose_swap() {
    read -p "Enter Swap Interval (0-5, default 1): " swap
    if ! [[ $swap =~ ^[0-5]$ ]]; then
        echo -e "${RED}Invalid input! Using 1.${NC}"
        SWAP=1
    else
        SWAP=$swap
    fi
}
check_current() {
    echo -e "${RED}Checking current Quest settings...${NC}"
    current_fps=$("$ADB_PATH" shell getprop debug.oculus.refreshRate)
    current_swap=$("$ADB_PATH" shell getprop debug.oculus.swapInterval)
    echo -e "${RED}Current Refresh Rate:${NC} $current_fps"
    echo -e "${RED}Current Swap Interval:${NC} $current_swap"
    read -p "Press Enter to return to menu..."
}
auto_wireless_connect() {
    USB_DEVICE=$($ADB_PATH devices | grep -w "device" | grep -v "emulator" | awk '{print $1}' | head -n1)
    if [ -z "$USB_DEVICE" ]; then
        echo -e "${RED}No USB Quest detected. Please connect via USB at least once.${NC}"
        sleep 2
        return
    fi
    echo -e "${RED}Detected USB Quest: $USB_DEVICE${NC}"
    $ADB_PATH -s "$USB_DEVICE" tcpip 5555
    sleep 1
    QUEST_IP=$($ADB_PATH -s "$USB_DEVICE" shell ip addr show wlan0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
    if [ -z "$QUEST_IP" ]; then
        echo -e "${RED}Failed to get IP from Quest. Make sure Wi-Fi is enabled.${NC}"
        sleep 2
        return
    fi
    echo -e "${RED}Connecting wirelessly to $QUEST_IP...${NC}"
    $ADB_PATH connect "$QUEST_IP:5555"
    sleep 1
    echo -e "${RED}Wireless connection established!${NC}"
}
while true; do
    ascii_banner
    echo "Select an option:"
    echo "1) Set FPS / Swap Interval"
    echo "2) Check current FPS / Swap Interval"
    echo "3) Connect Quest Wirelessly (auto-detect IP)"
    echo "q) Quit"
    read -p "Choice: " MAINCHOICE
    case $MAINCHOICE in
        1)
            choose_fps
            choose_swap
            echo -e "${RED}You selected:${NC} FPS=$FPS, Swap Interval=$SWAP"
            read -p "Apply these settings? (y/n): " CONFIRM
            if [[ "$CONFIRM" == "y" || "$CONFIRM" == "Y" ]]; then
                matrix_rain
                "$ADB_PATH" shell setprop debug.oculus.refreshRate "$FPS"
                "$ADB_PATH" shell setprop debug.oculus.swapInterval "$SWAP"
                echo -e "${RED}Settings applied!${NC}"
                echo "FPS: $FPS"
                echo "Swap Interval: $SWAP"
                sleep 2
            else
                echo -e "${RED}Cancelled, returning to menu...${NC}"
                sleep 1
            fi
            ;;
        2)
            check_current
            ;;
        3)
            auto_wireless_connect
            ;;
        q|Q)
            echo -e "${RED}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice, try again.${NC}"
            sleep 1
            ;;
    esac
done
