#!/data/data/com.termux/files/usr/bin/bash

# =========================================
# SnapX - Termux/Linux Backup Utility
# =========================================

BASE="$HOME/.backup"

# =========================================
# Colors
# =========================================

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

# =========================================
# Header
# =========================================

header() {

    echo -e "${BLUE}"
    echo "========================================="
    echo " SnapX - Backup Utility"
    echo " Termux + Linux Compatible"
    echo "========================================="
    echo -e "${RESET}"
}

# =========================================
# Check tar
# =========================================

check_tar() {

    if ! command -v tar >/dev/null 2>&1; then

        echo -e "${RED}✖ tar is not installed.${RESET}"
        echo ""

        echo -e "${YELLOW}Install tar:${RESET}"
        echo ""

        if command -v pkg >/dev/null 2>&1; then
            echo "Termux:"
            echo "  pkg install tar"
        else
            echo "Ubuntu/Debian:"
            echo "  sudo apt install tar"
            echo ""
            echo "Arch:"
            echo "  sudo pacman -S tar"
        fi

        echo ""
        exit 1
    fi
}

# =========================================
# Help
# =========================================

show_help() {

    header

    echo -e "${GREEN}Usage:${RESET}"
    echo ""

    echo "  snapx backup <project-folder>"
    echo "  snapx backup <project-folder> --raw"
    echo "  snapx restore <backup-file>"
    echo "  snapx list"
    echo ""

    echo -e "${GREEN}Examples:${RESET}"
    echo ""

    echo "  snapx backup Pixie"
    echo "  snapx backup Pixie --raw"
    echo "  snapx restore ~/.backup/Pixie/file.tar.gz"
    echo "  snapx list"
    echo ""
}

# =========================================
# Excludes
# =========================================

EXCLUDES=(

    # Node.js
    --exclude='node_modules'
    --exclude='.next'
    --exclude='.nuxt'
    --exclude='.npm'

    # PHP
    --exclude='vendor'
    --exclude='.composer'

    # Python
    --exclude='__pycache__'
    --exclude='.venv'
    --exclude='venv'
    --exclude='.mypy_cache'
    --exclude='.pytest_cache'

    # Java
    --exclude='.gradle'
    --exclude='build'
    --exclude='target'

    # Rust
    --exclude='target'

    # Go
    --exclude='pkg'
    --exclude='bin'

    # Dart / Flutter
    --exclude='.dart_tool'
    --exclude='.flutter-plugins'

    # C / C++
    --exclude='*.o'
    --exclude='*.out'
    --exclude='*.a'
    --exclude='*.so'

    # IDE
    --exclude='.idea'
    --exclude='.vscode'

    # OS
    --exclude='.DS_Store'
    --exclude='Thumbs.db'

    # SnapX
    --exclude='.backup'

    # Media
    --exclude='*.mp3'
    --exclude='*.mp4'
    --exclude='*.jpg'
    --exclude='*.jpeg'
    --exclude='*.png'
    --exclude='*.gif'
    --exclude='*.webp'
    --exclude='*.mkv'
    --exclude='*.avi'
    --exclude='*.mov'

)

# =========================================
# Backup
# =========================================

backup_project() {

    PROJECT=$1
    MODE=$2

    if [ -z "$PROJECT" ]; then
        echo -e "${RED}✖ Project folder required.${RESET}"
        exit 1
    fi

    if [ ! -d "$PROJECT" ]; then
        echo -e "${RED}✖ Project folder not found.${RESET}"
        exit 1
    fi

    NAME=$(basename "$PROJECT")

    BACKUP_DIR="$BASE/$NAME"

    mkdir -p "$BACKUP_DIR"

    DATE=$(date +%Y%m%d-%H%M%S)

    if [ "$MODE" == "--raw" ]; then

        FILE="$BACKUP_DIR/${NAME}-${DATE}.tar"

        echo -e "${YELLOW}➜ Creating raw backup...${RESET}"

        tar "${EXCLUDES[@]}" -cvf "$FILE" "$PROJECT"

    else

        FILE="$BACKUP_DIR/${NAME}-${DATE}.tar.gz"

        echo -e "${YELLOW}➜ Creating compressed backup...${RESET}"

        tar "${EXCLUDES[@]}" -czvf "$FILE" "$PROJECT"

    fi

    echo ""
    echo -e "${GREEN}✔ Backup created successfully.${RESET}"
    echo -e "${BLUE}${FILE}${RESET}"
    echo ""
}

# =========================================
# Restore
# =========================================

restore_backup() {

    FILE=$1

    if [ -z "$FILE" ]; then
        echo -e "${RED}✖ Backup file required.${RESET}"
        exit 1
    fi

    if [ ! -f "$FILE" ]; then
        echo -e "${RED}✖ Backup file not found.${RESET}"
        exit 1
    fi

    echo -e "${YELLOW}➜ Restoring backup...${RESET}"

    case "$FILE" in

        *.tar.gz)
            tar -xzvf "$FILE"
            ;;

        *.tar)
            tar -xvf "$FILE"
            ;;

        *)
            echo -e "${RED}✖ Unsupported backup format.${RESET}"
            exit 1
            ;;

    esac

    echo ""
    echo -e "${GREEN}✔ Backup restored successfully.${RESET}"
    echo ""
}

# =========================================
# List Backups
# =========================================

list_backups() {

    if [ ! -d "$BASE" ]; then
        echo -e "${RED}✖ No backups found.${RESET}"
        exit 1
    fi

    header

    echo -e "${GREEN}Available Backups:${RESET}"
    echo ""

    find "$BASE" -type f \( -name "*.tar.gz" -o -name "*.tar" \) | sort

    echo ""
}

# =========================================
# Main
# =========================================

check_tar

COMMAND=$1

case "$COMMAND" in

    backup)
        backup_project "$2" "$3"
        ;;

    restore)
        restore_backup "$2"
        ;;

    list)
        list_backups
        ;;

    *)
        show_help
        ;;

esac
