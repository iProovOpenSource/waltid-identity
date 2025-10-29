#!/bin/bash

# Set up logging
LOG_FILE="build_libraries.log"
exec 1> >(tee -a "$LOG_FILE") 2>&1
echo "=== Build started at $(date) ===" > "$LOG_FILE"

# Builds all waltid required libraries using Gradle
echo "Building waltid libraries..."
./gradlew waltid-libraries:build

# Prefixes
lib_prefix=":waltid-libraries"
credentials_prefix="$lib_prefix:credentials"
crypto_prefix="$lib_prefix:crypto"
did_prefix="$lib_prefix:waltid-did"
mdoc_credentials_prefix="$lib_prefix:mdoc-credentials"
dif_definitions_parser_prefix="$lib_prefix:dif-definitions-parser"
policies_prefix="$lib_prefix:policies"
sdjwt_prefix="$lib_prefix:sdjwt"
openid4vc_prefix="$lib_prefix:protocols"

local_maven_repo="$HOME/.m2/repository"
waltid_group_path="id/walt"
repo_base_path="./maven"

# Credentials
credentials_modules=(
    ":waltid-mdoc-credentials2"
    ":waltid-w3c-credentials"
    ":waltid-dif-definitions-parser"
    ":waltid-verification-policies"
    ":waltid-mdoc-credentials"
)

# Crypto
crypto_modules=(
    ":waltid-cose"
    ":waltid-target-ios"
    ":waltid-crypto"
    ":waltid-crypto-ios"
)

# SD-JWT
sdjwt_modules=(
    ":waltid-sdjwt"
    ":waltid-sdjwt-ios"
)

# OpenID4VC
openid4vc_modules=(
    ":waltid-openid4vc"
)

# Build Credentials modules
for module in "${credentials_modules[@]}"; do
    ./gradlew "$credentials_prefix$module:publishToMavenLocal"
done

# Build Crypto modules
for module in "${crypto_modules[@]}"; do
    ./gradlew "$crypto_prefix$module:publishToMavenLocal"
done

# Build DID modules
./gradlew "$did_prefix:publishToMavenLocal"

# Build MDOC Credentials modules
for module in "${mdoc_credentials_modules[@]}"; do
    ./gradlew "$mdoc_credentials_prefix$module:publishToMavenLocal"
done

# Build SD-JWT modules
for module in "${sdjwt_modules[@]}"; do
    ./gradlew "$sdjwt_prefix$module:publishToMavenLocal"
done

# Build OpenID4VC modules
for module in "${openid4vc_modules[@]}"; do
    ./gradlew "$openid4vc_prefix$module:publishToMavenLocal"
done



echo "All required libraries have been built and published to the local Maven repository."

echo "Copying from the local Maven repository to the project's libs directory."

# delete the existing libs directory if it exists
rm -rf "$repo_base_path/$waltid_group_path"

# Create the directory structure
mkdir -p "$repo_base_path/$waltid_group_path"

# Copy the built libraries from the local Maven repository to the project's libs directory
cp -r "$local_maven_repo/$waltid_group_path/"* "$repo_base_path/$waltid_group_path/"

echo "All required libraries have been copied to $repo_base_path/$waltid_group_path."

echo "=== Build completed at $(date) ===" >> "$LOG_FILE"
