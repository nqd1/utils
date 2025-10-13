#!/bin/bash
# auto commit and push with custom date
# note: for educational/testing purposes only

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_usage() {
    echo -e "${YELLOW}auto commit with custom date${NC}"
    echo ""
    echo "usage: $0 [options]"
    echo ""
    echo "options:"
    echo "  -m MESSAGE    commit message (default: 'auto commit')"
    echo "  -d DATE       date for commit (format: 'YYYY-MM-DD HH:MM:SS')"
    echo "  -r DAYS       random commit within last N days"
    echo "  -p            push after commit"
    echo "  -b BRANCH     branch to push (default: current branch)"
    echo ""
    echo "examples:"
    echo "  $0 -m 'feature update' -d '2024-01-15 10:30:00' -p"
    echo "  $0 -m 'bug fix' -r 7 -p"
    exit 1
}

# defaults
MESSAGE="auto commit"
CUSTOM_DATE=""
RANDOM_DAYS=0
PUSH=false
BRANCH=""

# parse arguments
while getopts "m:d:r:pb:h" opt; do
    case $opt in
        m) MESSAGE="$OPTARG";;
        d) CUSTOM_DATE="$OPTARG";;
        r) RANDOM_DAYS="$OPTARG";;
        p) PUSH=true;;
        b) BRANCH="$OPTARG";;
        h) show_usage;;
        *) show_usage;;
    esac
done

# check if git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}not a git repository${NC}"
    exit 1
fi

# generate random date if requested
if [ "$RANDOM_DAYS" -gt 0 ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macos
        RANDOM_SECONDS=$((RANDOM % (RANDOM_DAYS * 86400)))
        CUSTOM_DATE=$(date -v-${RANDOM_SECONDS}S "+%Y-%m-%d %H:%M:%S")
    else
        # linux
        RANDOM_SECONDS=$((RANDOM % (RANDOM_DAYS * 86400)))
        CUSTOM_DATE=$(date -d "-$RANDOM_SECONDS seconds" "+%Y-%m-%d %H:%M:%S")
    fi
    echo -e "${BLUE}random date: $CUSTOM_DATE${NC}"
fi

# stage all changes
echo -e "${GREEN}staging changes...${NC}"
git add -A

# check if there are changes
if git diff --cached --quiet; then
    echo -e "${YELLOW}no changes to commit${NC}"
    exit 0
fi

# commit with custom date if provided
if [ -n "$CUSTOM_DATE" ]; then
    echo -e "${GREEN}committing with custom date: $CUSTOM_DATE${NC}"
    GIT_AUTHOR_DATE="$CUSTOM_DATE" GIT_COMMITTER_DATE="$CUSTOM_DATE" git commit -m "$MESSAGE"
else
    echo -e "${GREEN}committing with current date...${NC}"
    git commit -m "$MESSAGE"
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}commit successful${NC}"
    
    # push if requested
    if $PUSH; then
        if [ -z "$BRANCH" ]; then
            BRANCH=$(git rev-parse --abbrev-ref HEAD)
        fi
        
        echo -e "${GREEN}pushing to $BRANCH...${NC}"
        git push origin "$BRANCH"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}push successful${NC}"
        else
            echo -e "${RED}push failed${NC}"
            exit 1
        fi
    fi
else
    echo -e "${RED}commit failed${NC}"
    exit 1
fi

echo -e "${GREEN}done${NC}"
