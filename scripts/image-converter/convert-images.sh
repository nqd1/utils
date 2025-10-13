#!/bin/bash
# batch convert images (requires imagemagick)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_usage() {
    echo -e "${YELLOW}batch convert images${NC}"
    echo ""
    echo "usage: $0 [options]"
    echo ""
    echo "options:"
    echo "  -s SOURCE     source directory with images (default: ./images)"
    echo "  -d DEST       destination directory (default: ./converted)"
    echo "  -f FORMAT     target format (jpg, png, webp, gif, etc.)"
    echo "  -q QUALITY    quality (1-100, default: 85)"
    echo "  -r WIDTHxHEIGHT  resize images (e.g. 1920x1080)"
    echo "  -p PERCENT    resize by percentage (e.g. 50)"
    echo "  -k            keep aspect ratio when resizing"
    echo ""
    echo "examples:"
    echo "  $0 -s ./photos -f webp -q 80"
    echo "  $0 -s ./images -f jpg -r 1920x1080 -k"
    echo "  $0 -f png -p 50"
    echo ""
    echo "note: requires imagemagick (install: sudo apt-get install imagemagick)"
    exit 1
}

# defaults
SOURCE="./images"
DEST="./converted"
FORMAT=""
QUALITY=85
RESIZE=""
PERCENT=""
KEEP_ASPECT=false

# parse arguments
while getopts "s:d:f:q:r:p:kh" opt; do
    case $opt in
        s) SOURCE="$OPTARG";;
        d) DEST="$OPTARG";;
        f) FORMAT="$OPTARG";;
        q) QUALITY="$OPTARG";;
        r) RESIZE="$OPTARG";;
        p) PERCENT="$OPTARG";;
        k) KEEP_ASPECT=true;;
        h) show_usage;;
        *) show_usage;;
    esac
done

# check imagemagick
if ! command -v convert &> /dev/null; then
    echo -e "${RED}imagemagick not installed${NC}"
    echo -e "${YELLOW}install: sudo apt-get install imagemagick${NC}"
    echo -e "${YELLOW}or: brew install imagemagick${NC}"
    exit 1
fi

# check format
if [ -z "$FORMAT" ]; then
    echo -e "${RED}please specify target format (-f)${NC}"
    show_usage
fi

# check source
if [ ! -d "$SOURCE" ]; then
    echo -e "${RED}source directory not found: $SOURCE${NC}"
    exit 1
fi

# create destination directory
mkdir -p "$DEST"

echo -e "${YELLOW}image batch converter${NC}"
echo -e "${BLUE}source: $SOURCE${NC}"
echo -e "${BLUE}destination: $DEST${NC}"
echo -e "${BLUE}format: $FORMAT${NC}"
echo -e "${BLUE}quality: $QUALITY${NC}"
if [ -n "$RESIZE" ]; then
    echo -e "${BLUE}resize: $RESIZE${NC}"
fi
if [ -n "$PERCENT" ]; then
    echo -e "${BLUE}resize: $PERCENT%${NC}"
fi
echo ""

# find all images
shopt -s nullglob
IMAGES=("$SOURCE"/*.{jpg,jpeg,png,gif,bmp,webp,tiff,JPG,JPEG,PNG,GIF,BMP,WEBP,TIFF})

if [ ${#IMAGES[@]} -eq 0 ]; then
    echo -e "${RED}no images found in $SOURCE${NC}"
    exit 1
fi

echo -e "${BLUE}found ${#IMAGES[@]} image(s)${NC}"
echo ""

# convert each image
success=0
failed=0

for img in "${IMAGES[@]}"; do
    filename=$(basename "$img")
    name="${filename%.*}"
    output="$DEST/${name}.$FORMAT"
    
    echo -e "${GREEN}converting: $filename${NC}"
    
    # build convert command
    cmd="convert \"$img\""
    
    if [ -n "$RESIZE" ]; then
        if $KEEP_ASPECT; then
            cmd="$cmd -resize \"$RESIZE>\""
        else
            cmd="$cmd -resize \"$RESIZE!\""
        fi
    fi
    
    if [ -n "$PERCENT" ]; then
        cmd="$cmd -resize \"$PERCENT%\""
    fi
    
    cmd="$cmd -quality $QUALITY \"$output\""
    
    # execute
    eval $cmd 2>/dev/null
    
    if [ $? -eq 0 ]; then
        orig_size=$(du -h "$img" | cut -f1)
        new_size=$(du -h "$output" | cut -f1)
        echo -e "${GREEN}  $orig_size -> $new_size${NC}"
        ((success++))
    else
        echo -e "${RED}  failed${NC}"
        ((failed++))
    fi
done

echo ""
echo -e "${GREEN}done${NC}"
echo -e "${BLUE}total: ${#IMAGES[@]} image(s)${NC}"
echo -e "${GREEN}success: $success${NC}"
if [ $failed -gt 0 ]; then
    echo -e "${RED}failed: $failed${NC}"
fi
