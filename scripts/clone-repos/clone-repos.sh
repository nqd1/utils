#!/bin/bash
# clone multiple repositories from urls file

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_usage() {
    echo -e "${YELLOW}clone multiple repositories${NC}"
    echo ""
    echo "usage: $0 [options]"
    echo ""
    echo "options:"
    echo "  -f FILE       file with URLs list (default: urls.txt)"
    echo "  -d DIR        destination directory (default: ./repos)"
    echo "  -b BRANCH     branch to checkout (default: main/master)"
    echo "  -s            shallow clone (latest commit only)"
    echo "  -p            clone in parallel"
    echo ""
    echo "urls file format (one URL per line):"
    echo "  https://github.com/user/repo1.git"
    echo "  https://github.com/user/repo2.git"
    echo "  git@github.com:user/repo3.git"
    echo ""
    echo "examples:"
    echo "  $0 -f repos.txt -d ./projects"
    echo "  $0 -f urls.txt -s -p"
    exit 1
}

# defaults
URL_FILE="urls.txt"
DEST_DIR="./repos"
BRANCH=""
SHALLOW=false
PARALLEL=false

# parse arguments
while getopts "f:d:b:sph" opt; do
    case $opt in
        f) URL_FILE="$OPTARG";;
        d) DEST_DIR="$OPTARG";;
        b) BRANCH="$OPTARG";;
        s) SHALLOW=true;;
        p) PARALLEL=true;;
        h) show_usage;;
        *) show_usage;;
    esac
done

# check if urls file exists
if [ ! -f "$URL_FILE" ]; then
    echo -e "${RED}file not found: $URL_FILE${NC}"
    echo -e "${YELLOW}creating sample urls.txt...${NC}"
    cat > urls.txt << 'EOF'
# add git repository URLs here (one per line)
# examples:
# https://github.com/user/repo1.git
# https://github.com/user/repo2.git
# git@github.com:user/repo3.git
EOF
    echo -e "${GREEN}created sample urls.txt, please add URLs and run again${NC}"
    exit 0
fi

# create destination directory
mkdir -p "$DEST_DIR"

echo -e "${YELLOW}clone multiple repositories${NC}"
echo -e "${BLUE}source: $URL_FILE${NC}"
echo -e "${BLUE}destination: $DEST_DIR${NC}"
echo ""

# read URLs from file (skip empty lines and comments)
mapfile -t URLS < <(grep -v '^\s*#' "$URL_FILE" | grep -v '^\s*$')

if [ ${#URLS[@]} -eq 0 ]; then
    echo -e "${RED}no URLs found in file${NC}"
    exit 1
fi

echo -e "${BLUE}found ${#URLS[@]} repository/repositories${NC}"
echo ""

# function to clone a repo
clone_repo() {
    local url=$1
    local repo_name=$(basename "$url" .git)
    local clone_path="$DEST_DIR/$repo_name"
    
    if [ -d "$clone_path" ]; then
        echo -e "${YELLOW}$repo_name already exists, pulling updates...${NC}"
        cd "$clone_path"
        git pull
        cd - > /dev/null
    else
        echo -e "${GREEN}cloning $repo_name...${NC}"
        
        local clone_cmd="git clone"
        
        if $SHALLOW; then
            clone_cmd="$clone_cmd --depth 1"
        fi
        
        if [ -n "$BRANCH" ]; then
            clone_cmd="$clone_cmd -b $BRANCH"
        fi
        
        $clone_cmd "$url" "$clone_path"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}cloned $repo_name${NC}"
        else
            echo -e "${RED}failed to clone $repo_name${NC}"
        fi
    fi
}

# clone repositories
success=0
failed=0

if $PARALLEL; then
    # clone in parallel
    echo -e "${BLUE}cloning in parallel mode...${NC}"
    for url in "${URLS[@]}"; do
        clone_repo "$url" &
    done
    wait
else
    # clone sequentially
    for url in "${URLS[@]}"; do
        clone_repo "$url"
        if [ $? -eq 0 ]; then
            ((success++))
        else
            ((failed++))
        fi
    done
fi

echo ""
echo -e "${GREEN}done${NC}"
echo -e "${BLUE}total: ${#URLS[@]} repositories${NC}"

if ! $PARALLEL; then
    echo -e "${GREEN}success: $success${NC}"
    if [ $failed -gt 0 ]; then
        echo -e "${RED}failed: $failed${NC}"
    fi
fi
