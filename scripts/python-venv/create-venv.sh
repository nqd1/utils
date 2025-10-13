#!/bin/bash
# create python virtual environment and install dependencies

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# venv name (default is 'venv')
VENV_NAME="${1:-venv}"

echo -e "${YELLOW}creating python virtual environment: $VENV_NAME${NC}"

# check if python is installed
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}python3 not found, please install it first${NC}"
    exit 1
fi

# create virtual environment
echo -e "${GREEN}creating virtual environment...${NC}"
python3 -m venv "$VENV_NAME"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}virtual environment created successfully${NC}"
    
    # activate venv
    source "$VENV_NAME/bin/activate"
    
    # upgrade pip
    echo -e "${GREEN}upgrading pip...${NC}"
    pip install --upgrade pip
    
    # install requirements.txt if exists
    if [ -f "requirements.txt" ]; then
        echo -e "${GREEN}found requirements.txt, installing dependencies...${NC}"
        pip install -r requirements.txt
    fi
    
    echo -e "${GREEN}done! use 'source $VENV_NAME/bin/activate' to activate${NC}"
else
    echo -e "${RED}failed to create virtual environment${NC}"
    exit 1
fi
