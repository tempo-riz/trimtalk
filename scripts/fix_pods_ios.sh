#!/bin/bash

# Go to the ios folder inside your Project
cd ios || {
    echo "Directory not found (check where you are running the script)"
    exit 1
}

# Delete Podfile.lock
rm -f Podfile.lock

# Clear symlinks folder
rm -f -r .symlinks

# Clear Pods folder
rm -f -r Pods

# Remove trunk repo from pod
pod repo remove trunk

# Install pods using arch -x86_64
arch -x86_64 pod install --repo-update

# Move back to the parent directory
cd ..

flutter clean

flutter pub get
