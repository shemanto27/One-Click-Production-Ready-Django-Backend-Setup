#!/bin/bash

# Deletes everything in the current directory except for these two files
echo "Cleaning up directory..."

find . -maxdepth 1 ! -name 'delete.sh' ! -name 'init.sh' ! -name 'README.md' ! -name 'LICENSE' ! -name '.git' ! -name '.' -exec rm -rf {} +

# also remove pre-commit hook if it was installed during testing
if [ -f ".git/hooks/pre-commit" ]; then
    rm ".git/hooks/pre-commit"
fi

echo "Cleanup complete. Remaining files:"
ls -A
