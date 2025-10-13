#!/bin/bash
# backup files and folders with timestamp

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_usage() {
    echo -e "${YELLOW}backup files/folders${NC}"
    echo ""
    echo "usage: $0 [options]"
    echo ""
    echo "options:"
    echo "  -s SOURCE     source directory/file to backup"
    echo "  -d DEST       destination directory for backups (default: ./backups)"
    echo "  -z            compress backup as .tar.gz"
    echo "  -k DAYS       keep backups for N days (delete older)"
    echo "  -n NAME       custom name for backup (default: source name)"
    echo "  -e EXCLUDE    exclude pattern (can use multiple times)"
    echo ""
    echo "examples:"
    echo "  $0 -s ./project -d ./backups -z"
    echo "  $0 -s ./data -z -k 7"
    echo "  $0 -s ./app -e '*.log' -e 'node_modules' -z"
    exit 1
}

# defaults
SOURCE=""
DEST="./backups"
COMPRESS=false
KEEP_DAYS=0
CUSTOM_NAME=""
EXCLUDES=()

# parse arguments
while getopts "s:d:zk:n:e:h" opt; do
    case $opt in
        s) SOURCE="$OPTARG";;
        d) DEST="$OPTARG";;
        z) COMPRESS=true;;
        k) KEEP_DAYS="$OPTARG";;
        n) CUSTOM_NAME="$OPTARG";;
        e) EXCLUDES+=("$OPTARG");;
        h) show_usage;;
        *) show_usage;;
    esac
done

# check source
if [ -z "$SOURCE" ]; then
    echo -e "${RED}please specify source (-s)${NC}"
    show_usage
fi

if [ ! -e "$SOURCE" ]; then
    echo -e "${RED}source not found: $SOURCE${NC}"
    exit 1
fi

# create backup directory
mkdir -p "$DEST"

# create timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# backup name
if [ -z "$CUSTOM_NAME" ]; then
    BASENAME=$(basename "$SOURCE")
else
    BASENAME="$CUSTOM_NAME"
fi

echo -e "${YELLOW}backup script${NC}"
echo -e "${BLUE}source: $SOURCE${NC}"
echo -e "${BLUE}destination: $DEST${NC}"
echo ""

if $COMPRESS; then
    # backup and compress
    BACKUP_FILE="${DEST}/${BASENAME}_${TIMESTAMP}.tar.gz"
    echo -e "${GREEN}creating compressed backup: $BACKUP_FILE${NC}"
    
    # build tar command with excludes
    TAR_CMD="tar -czf \"$BACKUP_FILE\""
    for exclude in "${EXCLUDES[@]}"; do
        TAR_CMD="$TAR_CMD --exclude=\"$exclude\""
    done
    TAR_CMD="$TAR_CMD -C \"$(dirname "$SOURCE")\" \"$(basename "$SOURCE")\""
    
    eval $TAR_CMD
    
    if [ $? -eq 0 ]; then
        SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        echo -e "${GREEN}backup created successfully, size: $SIZE${NC}"
    else
        echo -e "${RED}backup failed${NC}"
        exit 1
    fi
else
    # backup without compression
    BACKUP_DIR="${DEST}/${BASENAME}_${TIMESTAMP}"
    echo -e "${GREEN}creating backup: $BACKUP_DIR${NC}"
    
    # build rsync command with excludes
    RSYNC_CMD="rsync -av"
    for exclude in "${EXCLUDES[@]}"; do
        RSYNC_CMD="$RSYNC_CMD --exclude=\"$exclude\""
    done
    RSYNC_CMD="$RSYNC_CMD \"$SOURCE/\" \"$BACKUP_DIR\""
    
    eval $RSYNC_CMD
    
    if [ $? -eq 0 ]; then
        SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
        echo -e "${GREEN}backup created successfully, size: $SIZE${NC}"
    else
        echo -e "${RED}backup failed${NC}"
        exit 1
    fi
fi

# delete old backups if specified
if [ $KEEP_DAYS -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}cleaning old backups (older than $KEEP_DAYS days)...${NC}"
    
    if $COMPRESS; then
        PATTERN="${DEST}/${BASENAME}_*.tar.gz"
    else
        PATTERN="${DEST}/${BASENAME}_*"
    fi
    
    find "$DEST" -maxdepth 1 -name "${BASENAME}_*" -type f -mtime +$KEEP_DAYS -delete 2>/dev/null
    find "$DEST" -maxdepth 1 -name "${BASENAME}_*" -type d -mtime +$KEEP_DAYS -exec rm -rf {} \; 2>/dev/null
    
    echo -e "${GREEN}cleanup completed${NC}"
fi

echo -e "${GREEN}done${NC}"
