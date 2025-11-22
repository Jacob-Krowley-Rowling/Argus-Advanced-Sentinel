# Repository Build Scripts

This directory contains shell scripts for automating repository checkout and build operations across multiple repositories with built-in retry logic.

## Scripts

### checkout-and-build-all.sh
Main script for checking out and building multiple repositories with automatic retry on failure.

**Features:**
- Automatic retry logic for git operations (up to 3 attempts by default)
- Automatic retry logic for build operations
- Support for multiple build systems:
  - Node.js (npm)
  - Maven (Java)
  - Gradle (Java/Kotlin)
  - Make
  - Cargo (Rust)
  - Go
- Colored logging for better visibility
- Configurable retry attempts and delays
- Multiple configuration methods

**Usage:**
```bash
# Basic usage (uses default repositories)
./checkout-and-build-all.sh

# Using a configuration file
REPOS_FILE=repos.txt ./checkout-and-build-all.sh

# Passing repositories as arguments
./checkout-and-build-all.sh "https://github.com/user/repo1.git|repo1" "https://github.com/user/repo2.git|repo2"

# Custom configuration
MAX_RETRIES=5 RETRY_DELAY=10 REPOS_DIR=/custom/path ./checkout-and-build-all.sh
```

**Configuration:**

Environment variables:
- `MAX_RETRIES` - Number of retry attempts (default: 3)
- `RETRY_DELAY` - Delay between retries in seconds (default: 5)
- `REPOS_DIR` - Directory to clone repositories into (default: ./repos)
- `REPOS_FILE` - Path to a file containing repository configurations (one per line: URL|NAME)

### termux-checkout-and-build-all.sh
Termux-optimized version for Android devices.

**Features:**
- All features from the main script
- Termux environment detection
- Package availability checks
- Helpful installation suggestions for missing packages
- Optimized for mobile/Android environments

**Usage:**
```bash
# Make executable
chmod +x termux-checkout-and-build-all.sh

# Run in Termux
./termux-checkout-and-build-all.sh
```

**Prerequisites for Termux:**
```bash
# Install required packages
pkg install git nodejs python rust golang make
```

## Repository Configuration File Format

Create a text file (e.g., `repos.txt`) with one repository per line in the format:
```
URL|NAME
```

Example:
```
https://github.com/user/repo1.git|repo1
https://github.com/user/repo2.git|repo2
https://github.com/user/repo3.git|repo3
```

## Customizing the Scripts

### Adding Custom Repositories

Edit the `REPOSITORIES` array in the script:
```bash
REPOSITORIES=(
    "https://github.com/user/repo1.git|repo1"
    "https://github.com/user/repo2.git|repo2"
)
```

### Adding Support for Additional Build Systems

Add detection and build logic in the `build_repo` function:
```bash
elif [ -f "your-build-file" ]; then
    log_info "Detected your build system for $repo_name"
    retry_operation "Build $repo_name" your-build-command
```

## Error Handling

The scripts implement comprehensive error handling:
- Network failures during git operations are automatically retried
- Build failures are automatically retried
- Missing build tools are detected and reported
- Failed operations are logged with clear error messages

## Security

These scripts follow security best practices:
- No use of `eval` for command execution (prevents command injection)
- Proper quoting of variables
- Safe command execution using function arguments
- Input validation for repository paths

## Troubleshooting

**Issue:** Git clone/fetch failures
- **Solution:** Check network connection and repository URL. The script will automatically retry.

**Issue:** Build failures
- **Solution:** Check that required build tools are installed (npm, maven, etc.). The script will retry automatically.

**Issue:** Permission denied
- **Solution:** Make scripts executable: `chmod +x *.sh`

**Issue:** Termux-specific: Command not found
- **Solution:** Install missing package: `pkg install <package-name>`

## Examples

### Example 1: Build Multiple Projects
```bash
# Create repos.txt
cat > repos.txt << EOF
https://github.com/facebook/react.git|react
https://github.com/nodejs/node.git|node
EOF

# Run with custom settings
MAX_RETRIES=5 REPOS_FILE=repos.txt ./checkout-and-build-all.sh
```

### Example 2: Continuous Integration
```bash
#!/bin/bash
# ci-build.sh - Continuous integration build script

export MAX_RETRIES=3
export RETRY_DELAY=10
export REPOS_DIR=/var/ci/repos
export REPOS_FILE=/etc/ci/repositories.txt

./checkout-and-build-all.sh

if [ $? -eq 0 ]; then
    echo "All repositories built successfully"
else
    echo "Some repositories failed to build"
    exit 1
fi
```

## License

These scripts are part of the Argus Advanced Sentinel project.
