#!/bin/bash

# Colors for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Git Repository Manager ===${NC}"
echo "1) Push changes to remote"
echo "2) Pull changes from remote"
read -p "Choose operation (1/2): " operation

case $operation in
    1)
        # Push workflow
        echo -e "\n${YELLOW}Current git status:${NC}"
        git status

        echo -e "\n${YELLOW}Files to be added:${NC}"
        git status --porcelain

        read -p $'\nAdd all changes? (y/n): ' add_all
        if [[ $add_all == "y" || $add_all == "Y" ]]; then
            git add .
        else
            echo "Enter files to add (space-separated):"
            read -p "> " files_to_add
            git add $files_to_add
        fi

        echo -e "\n${YELLOW}Files staged for commit:${NC}"
        git status --porcelain

        read -p $'\nEnter commit message: ' commit_msg
        if [ -z "$commit_msg" ]; then
            echo -e "${RED}Error: Commit message cannot be empty${NC}"
            exit 1
        fi

        git commit -m "$commit_msg"

        echo -e "\n${YELLOW}Pushing to remote...${NC}"
        git push origin main

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Successfully pushed to remote!${NC}"
        else
            echo -e "${RED}Push failed. Please check error message above.${NC}"
        fi
        ;;
    2)
        # Pull workflow
        echo -e "\n${YELLOW}Checking local changes...${NC}"
        if [[ $(git status --porcelain) ]]; then
            echo -e "${RED}Warning: You have local changes that might be overwritten.${NC}"
            read -p "Continue with pull? (y/n): " continue_pull
            if [[ $continue_pull != "y" && $continue_pull != "Y" ]]; then
                echo "Pull aborted."
                exit 0
            fi
        fi

        echo -e "\n${YELLOW}Pulling from remote...${NC}"
        git pull origin main

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Successfully pulled from remote!${NC}"
        else
            echo -e "${RED}Pull failed. Please check error message above.${NC}"
        fi
        ;;
    *)
        echo -e "${RED}Invalid option. Please choose 1 or 2.${NC}"
        exit 1
        ;;
esac 