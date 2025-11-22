#!/bin/bash

# checkout-and-build-all.sh
# Script to checkout and build all repositories with retry logic
# This script handles repository operations across multiple repositories with automatic retry on failure

set -e

# Configuration
MAX_RETRIES=3
RETRY_DELAY=5
REPOS_DIR="${REPOS_DIR:-./repos}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Retry function for git operations
retry_git_operation() {
    local cmd="$1"
    local description="$2"
    local attempt=1
    
    while [ $attempt -le $MAX_RETRIES ]; do
        log_info "Attempt $attempt/$MAX_RETRIES: $description"
        
        if eval "$cmd"; then
            log_info "Success: $description"
            return 0
        else
            if [ $attempt -lt $MAX_RETRIES ]; then
                log_warn "Failed: $description. Retrying in ${RETRY_DELAY}s..."
                sleep $RETRY_DELAY
            else
                log_error "Failed after $MAX_RETRIES attempts: $description"
                return 1
            fi
        fi
        
        ((attempt++))
    done
}

# Retry function for build operations
retry_build_operation() {
    local cmd="$1"
    local description="$2"
    local attempt=1
    
    while [ $attempt -le $MAX_RETRIES ]; do
        log_info "Build attempt $attempt/$MAX_RETRIES: $description"
        
        if eval "$cmd"; then
            log_info "Build success: $description"
            return 0
        else
            if [ $attempt -lt $MAX_RETRIES ]; then
                log_warn "Build failed: $description. Retrying in ${RETRY_DELAY}s..."
                sleep $RETRY_DELAY
            else
                log_error "Build failed after $MAX_RETRIES attempts: $description"
                return 1
            fi
        fi
        
        ((attempt++))
    done
}

# Function to checkout or update a repository
checkout_repo() {
    local repo_url="$1"
    local repo_name="$2"
    local repo_path="$REPOS_DIR/$repo_name"
    
    if [ -d "$repo_path" ]; then
        log_info "Repository $repo_name already exists. Updating..."
        cd "$repo_path"
        retry_git_operation "git fetch --all" "Fetch updates for $repo_name"
        retry_git_operation "git pull" "Pull latest changes for $repo_name"
        cd - > /dev/null
    else
        log_info "Cloning repository $repo_name..."
        mkdir -p "$REPOS_DIR"
        retry_git_operation "git clone $repo_url $repo_path" "Clone $repo_name"
    fi
}

# Function to build a repository
build_repo() {
    local repo_name="$1"
    local repo_path="$REPOS_DIR/$repo_name"
    
    if [ ! -d "$repo_path" ]; then
        log_error "Repository path does not exist: $repo_path"
        return 1
    fi
    
    cd "$repo_path"
    
    # Detect build system and run appropriate build command
    if [ -f "package.json" ]; then
        log_info "Detected Node.js project for $repo_name"
        retry_build_operation "npm install" "Install dependencies for $repo_name"
        retry_build_operation "npm run build" "Build $repo_name"
    elif [ -f "pom.xml" ]; then
        log_info "Detected Maven project for $repo_name"
        retry_build_operation "mvn clean install" "Build $repo_name with Maven"
    elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
        log_info "Detected Gradle project for $repo_name"
        retry_build_operation "./gradlew build" "Build $repo_name with Gradle"
    elif [ -f "Makefile" ]; then
        log_info "Detected Makefile for $repo_name"
        retry_build_operation "make" "Build $repo_name with Make"
    elif [ -f "Cargo.toml" ]; then
        log_info "Detected Rust project for $repo_name"
        retry_build_operation "cargo build --release" "Build $repo_name with Cargo"
    elif [ -f "go.mod" ]; then
        log_info "Detected Go project for $repo_name"
        retry_build_operation "go build" "Build $repo_name with Go"
    else
        log_warn "No recognized build system found for $repo_name. Skipping build."
    fi
    
    cd - > /dev/null
}

# Main execution
main() {
    log_info "Starting checkout and build process for all repositories"
    
    # Example repository configuration
    # Add your repositories here in the format: "URL|NAME"
    # For this project, we'll use the current repository as an example
    REPOSITORIES=(
        "https://github.com/Jacob-Krowley-Rowling/Argus-Advanced-Sentinel.git|Argus-Advanced-Sentinel"
    )
    
    # Process each repository
    for repo_config in "${REPOSITORIES[@]}"; do
        IFS='|' read -r repo_url repo_name <<< "$repo_config"
        
        log_info "=== Processing repository: $repo_name ==="
        
        # Checkout or update repository
        if checkout_repo "$repo_url" "$repo_name"; then
            # Build repository
            build_repo "$repo_name"
        else
            log_error "Failed to checkout $repo_name. Skipping build."
        fi
        
        echo ""
    done
    
    log_info "Checkout and build process completed for all repositories"
}

# Run main function
main "$@"
