#!/bin/bash

COMMIT_MESSAGE=$1   #Argument for the commit message

#Checks if there is an argument
if [ -z "$COMMIT_MESSAGE" ]; then
        echo "Usage: ./git_push.sh <commit_message>"
        exit 1
fi

#Goes to the root of the repository
cd ~/flowcore

git add .
git commit -m "$COMMIT_MESSAGE"
git push origin main
