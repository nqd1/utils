#!/bin/bash
# search and replace text in files

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_usage() {
    echo -e "${YELLOW}search and replace text in files${NC}"
    echo ""
    echo "usage: $0 [options]"
    echo ""
    echo "options:"
    echo "  -s SEARCH     text/pattern to search (required)"
    echo "  -r REPLACE    replacement text"
    echo "  -d DIR        search directory (default: current directory)"
    echo "  -e EXT        file extension (e.g. .txt, .js)"
    echo "  -i            case insensitive"
    echo "  -w            whole word only"
    echo "  -g            use regex pattern"
    echo "  -p            preview only (don't replace)"
    echo "  -b            backup files before replacing"
    echo ""
    echo "examples:"
    echo "  $0 -s 'old_function' -r 'new_function' -e .js"
    echo "  $0 -s 'TODO' -d ./src -p"
    echo "  $0 -s 'console.log' -r '// console.log' -e .js -b"
    echo "  $0 -s '\btest\b' -r 'exam' -g -i"
    exit 1
}

# defaults
SEARCH=""
REPLACE=""
DIRECTORY="."
EXTENSION=""
CASE_INSENSITIVE=false
WHOLE_WORD=false
USE_REGEX=false
PREVIEW=false
BACKUP=false

# parse arguments
while getopts "s:r:d:e:iwgpbh" opt; do
    case $opt in
        s) SEARCH="$OPTARG";;
        r) REPLACE="$OPTARG";;
        d) DIRECTORY="$OPTARG";;
        e) EXTENSION="$OPTARG";;
        i) CASE_INSENSITIVE=true;;
        w) WHOLE_WORD=true;;
        g) USE_REGEX=true;;
        p) PREVIEW=true;;
        b) BACKUP=true;;
        h) show_usage;;
        *) show_usage;;
    esac
done

# check search
if [ -z "$SEARCH" ]; then
    echo -e "${RED}please specify search text (-s)${NC}"
    show_usage
fi

# check directory
if [ ! -d "$DIRECTORY" ]; then
    echo -e "${RED}directory not found: $DIRECTORY${NC}"
    exit 1
fi

echo -e "${YELLOW}search & replace script${NC}"
echo -e "${BLUE}directory: $DIRECTORY${NC}"
echo -e "${BLUE}search: '$SEARCH'${NC}"
if [ -n "$REPLACE" ]; then
    echo -e "${BLUE}replace: '$REPLACE'${NC}"
fi
if [ -n "$EXTENSION" ]; then
    echo -e "${BLUE}extension: $EXTENSION${NC}"
fi
if $PREVIEW; then
    echo -e "${YELLOW}mode: preview only${NC}"
fi
echo ""

# build grep options
GREP_OPTS="-r -n"
if $CASE_INSENSITIVE; then
    GREP_OPTS="$GREP_OPTS -i"
fi

if $WHOLE_WORD; then
    GREP_OPTS="$GREP_OPTS -w"
fi

# build find command
FIND_CMD="find \"$DIRECTORY\" -type f"
if [ -n "$EXTENSION" ]; then
    FIND_CMD="$FIND_CMD -name \"*$EXTENSION\""
fi

# search
echo -e "${GREEN}searching for '$SEARCH'...${NC}"
echo ""

declare -A file_matches
total_matches=0

while IFS= read -r file; do
    if grep -q $GREP_OPTS "$SEARCH" "$file" 2>/dev/null; then
        matches=$(grep -c $GREP_OPTS "$SEARCH" "$file" 2>/dev/null)
        file_matches["$file"]=$matches
        total_matches=$((total_matches + matches))
        
        echo -e "${BLUE}$file${NC} (${YELLOW}$matches match(es)${NC})"
        
        # show preview of matches
        grep $GREP_OPTS --color=always "$SEARCH" "$file" 2>/dev/null | head -n 5 | while read -r line; do
            echo -e "${GREEN}  $line${NC}"
        done
        
        if [ $(grep -c $GREP_OPTS "$SEARCH" "$file" 2>/dev/null) -gt 5 ]; then
            echo -e "${YELLOW}  ... and more${NC}"
        fi
        echo ""
    fi
done < <(eval $FIND_CMD)

# results
echo ""
echo -e "${BLUE}found $total_matches match(es) in ${#file_matches[@]} file(s)${NC}"

if [ ${#file_matches[@]} -eq 0 ]; then
    echo -e "${YELLOW}no matches found${NC}"
    exit 0
fi

# replace if not preview
if [ -n "$REPLACE" ] && ! $PREVIEW; then
    echo ""
    read -p "replace all occurrences? (y/n): " confirm
    
    if [ "$confirm" == "y" ] || [ "$confirm" == "Y" ]; then
        echo ""
        echo -e "${GREEN}replacing...${NC}"
        
        replaced_files=0
        
        for file in "${!file_matches[@]}"; do
            # backup if requested
            if $BACKUP; then
                cp "$file" "$file.bak"
            fi
            
            # replace
            if $USE_REGEX; then
                if $CASE_INSENSITIVE; then
                    sed -i'' -E "s/$SEARCH/$REPLACE/gI" "$file" 2>/dev/null
                else
                    sed -i'' -E "s/$SEARCH/$REPLACE/g" "$file" 2>/dev/null
                fi
            else
                # escape special characters for literal search
                SEARCH_ESC=$(printf '%s\n' "$SEARCH" | sed 's:[][\\/.^$*]:\\&:g')
                REPLACE_ESC=$(printf '%s\n' "$REPLACE" | sed 's:[\\/&]:\\&:g;s/$/\\/')
                REPLACE_ESC=${REPLACE_ESC%?}
                
                if $CASE_INSENSITIVE; then
                    sed -i'' "s/$SEARCH_ESC/$REPLACE_ESC/gI" "$file" 2>/dev/null
                else
                    sed -i'' "s/$SEARCH_ESC/$REPLACE_ESC/g" "$file" 2>/dev/null
                fi
            fi
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}  $file${NC}"
                ((replaced_files++))
            else
                echo -e "${RED}  failed: $file${NC}"
            fi
        done
        
        echo ""
        echo -e "${GREEN}replaced in $replaced_files file(s)${NC}"
        
        if $BACKUP; then
            echo -e "${BLUE}backup files created with .bak extension${NC}"
        fi
    else
        echo -e "${YELLOW}cancelled${NC}"
    fi
elif $PREVIEW; then
    echo -e "${YELLOW}preview mode - no changes made${NC}"
fi
