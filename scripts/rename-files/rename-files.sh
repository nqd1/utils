#!/bin/bash
# rename files by pattern and rules

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_usage() {
    echo -e "${YELLOW}rename files by pattern${NC}"
    echo ""
    echo "usage: $0 [options]"
    echo ""
    echo "options:"
    echo "  -e EXT        file extension to rename (e.g. .txt, .jpg)"
    echo "  -p PREFIX     add prefix to filename"
    echo "  -s SUFFIX     add suffix to filename (before extension)"
    echo "  -r FIND       find and replace: search string"
    echo "  -R REPLACE    find and replace: replacement string"
    echo "  -l            convert filename to lowercase"
    echo "  -u            convert filename to UPPERCASE"
    echo "  -n            number files (001, 002, ...)"
    echo "  -d DIR        target directory (default: current dir)"
    echo "  -y            auto confirm (no prompts)"
    echo ""
    echo "examples:"
    echo "  $0 -e .txt -p 'document_' -d ./files"
    echo "  $0 -e .jpg -n -d ./photos"
    echo "  $0 -e .md -r 'draft' -R 'final'"
    exit 1
}

# defaults
EXTENSION=""
PREFIX=""
SUFFIX=""
FIND=""
REPLACE=""
LOWERCASE=false
UPPERCASE=false
NUMBERING=false
DIRECTORY="."
AUTO_YES=false

# parse arguments
while getopts "e:p:s:r:R:lund:yh" opt; do
    case $opt in
        e) EXTENSION="$OPTARG";;
        p) PREFIX="$OPTARG";;
        s) SUFFIX="$OPTARG";;
        r) FIND="$OPTARG";;
        R) REPLACE="$OPTARG";;
        l) LOWERCASE=true;;
        u) UPPERCASE=true;;
        n) NUMBERING=true;;
        d) DIRECTORY="$OPTARG";;
        y) AUTO_YES=true;;
        h) show_usage;;
        *) show_usage;;
    esac
done

# check extension
if [ -z "$EXTENSION" ]; then
    echo -e "${RED}please specify extension (-e)${NC}"
    show_usage
fi

# check directory exists
if [ ! -d "$DIRECTORY" ]; then
    echo -e "${RED}directory not found: $DIRECTORY${NC}"
    exit 1
fi

# find files with extension
shopt -s nullglob
FILES=("$DIRECTORY"/*"$EXTENSION")

if [ ${#FILES[@]} -eq 0 ]; then
    echo -e "${RED}no files found with extension $EXTENSION in $DIRECTORY${NC}"
    exit 1
fi

echo -e "${BLUE}found ${#FILES[@]} file(s) with extension $EXTENSION${NC}"
echo ""

# preview rename
echo -e "${YELLOW}preview:${NC}"
counter=1
declare -A rename_map

for file in "${FILES[@]}"; do
    filename=$(basename "$file")
    name="${filename%$EXTENSION}"
    new_name="$name"
    
    # apply find/replace
    if [ -n "$FIND" ]; then
        new_name="${new_name//$FIND/$REPLACE}"
    fi
    
    # apply case
    if $LOWERCASE; then
        new_name=$(echo "$new_name" | tr '[:upper:]' '[:lower:]')
    elif $UPPERCASE; then
        new_name=$(echo "$new_name" | tr '[:lower:]' '[:upper:]')
    fi
    
    # apply numbering
    if $NUMBERING; then
        new_name=$(printf "%03d" $counter)
        ((counter++))
    fi
    
    # apply prefix/suffix
    new_name="${PREFIX}${new_name}${SUFFIX}"
    
    new_filename="${new_name}${EXTENSION}"
    
    if [ "$filename" != "$new_filename" ]; then
        echo -e "  ${GREEN}$filename${NC} -> ${BLUE}$new_filename${NC}"
        rename_map["$file"]="$DIRECTORY/$new_filename"
    fi
done

echo ""

# confirm
if ! $AUTO_YES; then
    read -p "continue renaming? (y/n): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo -e "${YELLOW}cancelled${NC}"
        exit 0
    fi
fi

# rename files
echo ""
echo -e "${GREEN}renaming...${NC}"
renamed=0
for file in "${!rename_map[@]}"; do
    new_path="${rename_map[$file]}"
    mv "$file" "$new_path" && ((renamed++))
done

echo -e "${GREEN}renamed $renamed file(s)${NC}"
