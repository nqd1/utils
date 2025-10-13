#!/bin/bash
# cleanup temp/cache files

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_usage() {
    echo -e "${YELLOW}cleanup temp/cache files${NC}"
    echo ""
    echo "usage: $0 [options]"
    echo ""
    echo "options:"
    echo "  -d DIR        directory to clean (default: current directory)"
    echo "  -t TYPE       cleanup type:"
    echo "                  all       - everything (default)"
    echo "                  node      - nodejs (node_modules, package-lock.json)"
    echo "                  python    - python (__pycache__, *.pyc, .pytest_cache)"
    echo "                  build     - build files (dist, build, out)"
    echo "                  cache     - cache files (.cache, *.tmp, *.log)"
    echo "                  temp      - temp files (*.tmp, *.temp, ~*)"
    echo "                  git       - git ignored files"
    echo "  -r            recursive (apply to all subdirectories)"
    echo "  -p            preview only (don't delete, just show)"
    echo "  -y            auto confirm (no prompts)"
    echo ""
    echo "examples:"
    echo "  $0 -t node -r"
    echo "  $0 -d ./project -t python -r"
    echo "  $0 -t cache -p"
    exit 1
}

# defaults
DIRECTORY="."
TYPE="all"
RECURSIVE=false
PREVIEW=false
AUTO_YES=false

# parse arguments
while getopts "d:t:rpyh" opt; do
    case $opt in
        d) DIRECTORY="$OPTARG";;
        t) TYPE="$OPTARG";;
        r) RECURSIVE=true;;
        p) PREVIEW=true;;
        y) AUTO_YES=true;;
        h) show_usage;;
        *) show_usage;;
    esac
done

# check directory
if [ ! -d "$DIRECTORY" ]; then
    echo -e "${RED}directory not found: $DIRECTORY${NC}"
    exit 1
fi

echo -e "${YELLOW}cleanup script${NC}"
echo -e "${BLUE}directory: $DIRECTORY${NC}"
echo -e "${BLUE}type: $TYPE${NC}"
if $PREVIEW; then
    echo -e "${YELLOW}mode: preview only${NC}"
fi
echo ""

# arrays for patterns
declare -a PATTERNS=()
declare -a DIRS=()

# add patterns based on type
case $TYPE in
    "node"|"all")
        DIRS+=("node_modules" ".npm")
        PATTERNS+=("package-lock.json" "yarn.lock" "pnpm-lock.yaml")
        ;;
esac

case $TYPE in
    "python"|"all")
        DIRS+=("__pycache__" ".pytest_cache" ".mypy_cache" "*.egg-info" ".tox" ".coverage")
        PATTERNS+=("*.pyc" "*.pyo" "*.pyd" ".Python")
        ;;
esac

case $TYPE in
    "build"|"all")
        DIRS+=("dist" "build" "out" ".next" ".nuxt" "target")
        ;;
esac

case $TYPE in
    "cache"|"all")
        DIRS+=(".cache" ".parcel-cache" ".eslintcache")
        PATTERNS+=("*.log" "*.cache")
        ;;
esac

case $TYPE in
    "temp"|"all")
        PATTERNS+=("*.tmp" "*.temp" "~*" "*.swp" "*.swo" ".DS_Store" "Thumbs.db")
        DIRS+=("tmp" "temp")
        ;;
esac

if [ "$TYPE" == "git" ]; then
    if [ -d "$DIRECTORY/.git" ]; then
        echo -e "${GREEN}cleaning git ignored files...${NC}"
        cd "$DIRECTORY"
        git clean -fdX
        cd - > /dev/null
        echo -e "${GREEN}done${NC}"
        exit 0
    else
        echo -e "${RED}not a git repository${NC}"
        exit 1
    fi
fi

# function to find and delete
cleanup_items() {
    local total_size=0
    local count=0
    
    # delete directories
    for dir_pattern in "${DIRS[@]}"; do
        if $RECURSIVE; then
            FIND_CMD="find \"$DIRECTORY\" -type d -name \"$dir_pattern\""
        else
            FIND_CMD="find \"$DIRECTORY\" -maxdepth 1 -type d -name \"$dir_pattern\""
        fi
        
        while IFS= read -r item; do
            if [ -d "$item" ]; then
                size=$(du -sh "$item" 2>/dev/null | cut -f1)
                echo -e "${YELLOW}  $item ($size)${NC}"
                
                if ! $PREVIEW; then
                    rm -rf "$item"
                    ((count++))
                fi
            fi
        done < <(eval $FIND_CMD 2>/dev/null)
    done
    
    # delete files
    for file_pattern in "${PATTERNS[@]}"; do
        if $RECURSIVE; then
            FIND_CMD="find \"$DIRECTORY\" -type f -name \"$file_pattern\""
        else
            FIND_CMD="find \"$DIRECTORY\" -maxdepth 1 -type f -name \"$file_pattern\""
        fi
        
        while IFS= read -r item; do
            if [ -f "$item" ]; then
                size=$(du -sh "$item" 2>/dev/null | cut -f1)
                echo -e "${YELLOW}  $item ($size)${NC}"
                
                if ! $PREVIEW; then
                    rm -f "$item"
                    ((count++))
                fi
            fi
        done < <(eval $FIND_CMD 2>/dev/null)
    done
    
    echo "$count"
}

# preview or confirm
echo -e "${GREEN}scanning for cleanup items...${NC}"
echo ""

count=$(cleanup_items)

echo ""
if $PREVIEW; then
    echo -e "${BLUE}preview completed, found items to clean${NC}"
    echo -e "${YELLOW}run without -p flag to actually delete${NC}"
else
    if ! $AUTO_YES; then
        read -p "delete these items? (y/n): " confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            echo -e "${YELLOW}cancelled${NC}"
            exit 0
        fi
    fi
    
    echo ""
    echo -e "${GREEN}cleaned up $count items${NC}"
fi
