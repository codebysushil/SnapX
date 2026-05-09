#!/bin/bash

# =========================================
# SnapX Installer
# Linux + Termux
# =========================================

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

REPO_URL="https://raw.githubusercontent.com/username/snapx/main/snapx"

echo -e "${BLUE}"
echo "========================================="
echo " SnapX Installer"
echo "========================================="
echo -e "${RESET}"

# =========================================
# Detect OS
# =========================================

detect_os() {

    if [ -n "$PREFIX" ] && command -v pkg >/dev/null 2>&1; then
        OS="termux"

    elif command -v apt >/dev/null 2>&1; then
        OS="debian"

    elif command -v pacman >/dev/null 2>&1; then
        OS="arch"

    elif command -v dnf >/dev/null 2>&1; then
        OS="fedora"

    else
        OS="unknown"
    fi
}

# =========================================
# Install Dependencies
# =========================================

install_dependencies() {

    echo -e "${YELLOW}➜ Checking dependencies...${RESET}"

    case "$OS" in

        termux)

            pkg update -y
            pkg install curl tar -y
            ;;

        debian)

            sudo apt update
            sudo apt install curl tar -y
            ;;

        arch)

            sudo pacman -Sy curl tar --noconfirm
            ;;

        fedora)

            sudo dnf install curl tar -y
            ;;

        *)

            echo -e "${RED}✖ Unsupported operating system.${RESET}"
            exit 1
            ;;

    esac
}

# =========================================
# Install SnapX
# =========================================

install_snapx() {

    echo ""
    echo -e "${YELLOW}➜ Downloading SnapX...${RESET}"

    curl -fsSL "$REPO_URL" -o snapx

    if [ $? -ne 0 ]; then
        echo -e "${RED}✖ Failed to download SnapX.${RESET}"
        exit 1
    fi

    chmod +x snapx

    echo ""
    echo -e "${YELLOW}➜ Installing SnapX...${RESET}"

    if [ "$OS" = "termux" ]; then

        mv snapx "$PREFIX/bin/snapx"

    else

        sudo mv snapx /usr/local/bin/snapx"

    fi

    echo ""
    echo -e "${GREEN}✔ SnapX installed successfully.${RESET}"
    echo ""

    snapx
}

# =========================================
# Main
# =========================================

detect_os
install_dependencies
install_snapx
