#!/bin/bash

# Function to update version in pubspec.yaml
update_version() {
    local file="pubspec.yaml"

    if [[ -f $file ]]; then
        # Read the current version from pubspec.yaml
        current_version=$(grep '^version:' "$file" | awk '{print $2}')

        if [[ -z $current_version ]]; then
            echo "No version found in $file!"
            exit 1
        fi

        # Split the version into name and build number
        IFS='+' read -r version_name version_code <<<"$current_version"

        # Increment the version name (major.minor.patch)
        IFS='.' read -r major minor patch <<<"$version_name"
        patch=$((patch + 1)) # Increment the patch number
        new_version_name="$major.$minor.$patch"

        # Increment the build number
        version_code=$((version_code + 1))
        new_version="$new_version_name+$version_code"

        # Update version in pubspec.yaml
        sed -i.bak "s/version: .*/version: $new_version/" "$file"
        echo "Updated version in $file to $new_version"
    else
        echo "File $file not found!"
        exit 1
    fi
}

# Update version by bumping it
update_version

# Build Android App Bundle
flutter build appbundle
ANDROID_BUILD_STATUS=$?

# Build iOS IPA
flutter build ipa
IOS_BUILD_STATUS=$?

# Check if both builds were successful
if [ $ANDROID_BUILD_STATUS -eq 0 ] && [ $IOS_BUILD_STATUS -eq 0 ]; then
    echo "Build successful. Proceeding to release..."
    # Navigate to Android directory and run Fastlane release
    cd android || exit
    bundle exec fastlane release
    echo "Android release completed successfully."

    # Navigate to iOS directory and run Fastlane release
    cd ../ios || exit
    bundle exec fastlane release
    echo "iOS release completed successfully."
else
    echo "Build failed. Please check the errors above."
    exit 1
fi

# flutter build appbundle
# # Navigate to Android directory and run Fastlane release
# cd android || exit
# bundle exec fastlane release

# # Navigate back to the root directory
# cd ..
# fluttter build ipa
# # Navigate to iOS directory and run Fastlane release
# cd ios || exit
# bundle exec fastlane release
