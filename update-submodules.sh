#!/bin/bash

# Get all submodule paths
submodules=$(git config --file .gitmodules --get-regexp path | awk '{ print $2 }')

# For each submodule, set it to track the main branch
for submodule in $submodules; do
  echo "Setting $submodule to track main branch..."
  git config -f .gitmodules submodule.$submodule.branch main
done

# Save changes and update all submodules
git submodule sync
git submodule update --remote --merge

echo "All submodules are now configured to track their main branches."
