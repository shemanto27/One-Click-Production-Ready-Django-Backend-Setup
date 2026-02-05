#!/bin/bash

# Deletes everything in the current directory except for these two files
echo "Cleaning up directory..."

find . -maxdepth 1 ! -name 'delete.sh' ! -name 'init.sh' ! -name '.' -exec rm -rf {} +

echo "Cleanup complete. Remaining files:"
ls -A
