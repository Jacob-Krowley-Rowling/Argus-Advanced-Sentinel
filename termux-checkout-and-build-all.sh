#!/data/data/com.termux/files/usr/bin/bash

# termux-checkout-and-build-all.sh
# Script to checkout and build all repositories with retry logic for Termux environment
# This script handles repository operations across multiple repositories with automatic retry on failure
# Optimized for Termux on Android devices

set -e

# Configuration
MAX_RETRIES=3
RETRY_DELAY=5
REPOS_DIR="${REPOS_DIR:-$HOME/repos}"

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

# Check Termux environment
check_termux_env() {
    if [ ! -d "/data/data/com.termux" ]; then
        log_warn "Not running in Termux environment. This script is optimized for Termux."
    fi
    
    # Check for required packages
    local required_packages=("git" "nodejs" "python")
    local missing_packages=()
    
    for pkg in "${required_packages[@]}"; do
        if ! command -v "$pkg" &> /dev/null; then
            missing_packages+=("$pkg")
        fi
    done
    
    if [ ${#missing_packages[@]} -gt 0 ]; then
        log_warn "Missing packages: ${missing_packages[*]}"
        log_info "Install with: pkg install ${missing_packages[*]}"
    fi
}

# Generic retry function that executes a command passed as arguments
retry_operation() {
    local description="$1"
    shift
    local attempt=1
    
    while [ $attempt -le $MAX_RETRIES ]; do
        log_info "Attempt $attempt/$MAX_RETRIES: $description"
        
        if "$@"; then
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

# Function to checkout or update a repository
checkout_repo() {
    local repo_url="$1"
    local repo_name="$2"
    local repo_path="$REPOS_DIR/$repo_name"
    
    if [ -d "$repo_path" ]; then
        log_info "Repository $repo_name already exists. Updating..."
        cd "$repo_path"
        retry_operation "Fetch updates for $repo_name" git fetch --all
        retry_operation "Pull latest changes for $repo_name" git pull
        cd - > /dev/null
    else
        log_info "Cloning repository $repo_name..."
        mkdir -p "$REPOS_DIR"
        retry_operation "Clone $repo_name" git clone "$repo_url" "$repo_path"
    fi
}

# Function to build a repository (Termux-specific)
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
        # Use npm if available, otherwise suggest installation
        if command -v npm &> /dev/null; then
            retry_operation "Install dependencies for $repo_name" npm install
            retry_operation "Build $repo_name" npm run build
        else
            log_error "npm not found. Install with: pkg install nodejs"
            cd - > /dev/null
            return 1
        fi
    elif [ -f "requirements.txt" ]; then
        log_info "Detected Python project for $repo_name"
        if command -v pip &> /dev/null; then
            retry_operation "Install Python dependencies for $repo_name" pip install -r requirements.txt
        else
            log_error "pip not found. Install with: pkg install python"
            cd - > /dev/null
            return 1
        fi
    elif [ -f "Cargo.toml" ]; then
        log_info "Detected Rust project for $repo_name"
        if command -v cargo &> /dev/null; then
            retry_operation "Build $repo_name with Cargo" cargo build --release
        else
            log_error "cargo not found. Install with: pkg install rust"
            cd - > /dev/null
            return 1
        fi
    elif [ -f "go.mod" ]; then
        log_info "Detected Go project for $repo_name"
        if command -v go &> /dev/null; then
            retry_operation "Build $repo_name with Go" go build
        else
            log_error "go not found. Install with: pkg install golang"
            cd - > /dev/null
            return 1
        fi
    elif [ -f "Makefile" ]; then
        log_info "Detected Makefile for $repo_name"
        if command -v make &> /dev/null; then
            retry_operation "Build $repo_name with Make" make
        else
            log_error "make not found. Install with: pkg install make"
            cd - > /dev/null
            return 1
        fi
    else
        log_warn "No recognized build system found for $repo_name. Skipping build."
    fi
    
    cd - > /dev/null
}

# Main execution
main() {
    log_info "Starting checkout and build process for all repositories (Termux)"
    
    # Check Termux environment
    check_termux_env
    
    # Repository configuration
    # You can customize this by:
    # 1. Editing the REPOSITORIES array below
    # 2. Setting REPOS_FILE environment variable to point to a file with repo configs (one per line: URL|NAME)
    # 3. Passing repositories as command line arguments
    
    # Check if repos are provided via file
    if [ -n "$REPOS_FILE" ] && [ -f "$REPOS_FILE" ]; then
        log_info "Loading repositories from $REPOS_FILE"
        mapfile -t REPOSITORIES < "$REPOS_FILE"
    # Check if repos are provided via command line
    elif [ $# -gt 0 ]; then
        REPOSITORIES=("$@")
    else
        # Default repository configuration
        # Add your repositories here in the format: "URL|NAME"
        REPOSITORIES=(
            "https://github.com/Jacob-Krowley-Rowling/Argus-Advanced-Sentinel.git|Argus-Advanced-Sentinel"
        )
    fi
    
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
