#!/bin/bash

# Claude Code Toolkit Installer
# Safely installs Claude hooks, agents, and MCP configuration to any directory
# Usage: curl https://raw.githubusercontent.com/Mandalorian007/claude-code-toolkit/main/install.sh | bash

set -e

# Configuration
REPO_URL="https://github.com/Mandalorian007/claude-code-toolkit"
TEMP_DIR=$(mktemp -d)
CURRENT_DIR=$(pwd)
BACKUP_DIR=".claude-toolkit-backup-$(date +%s)"
NEEDS_BACKUP=false

# Required environment variables
REQUIRED_ENV_VARS=(
    "ENGINEER_NAME=your-name-here  # TODO: Your name for TTS personalization"
    "ELEVENLABS_API_KEY=your-elevenlabs-key  # TODO: Get from https://elevenlabs.io"
    "ELEVENLABS_VOICE_ID=aUNOP2y8xEvi4nZebjIw  # TODO: Choose voice ID from ElevenLabs"
    "PERPLEXITY_API_KEY=your-perplexity-key  # TODO: Get from https://docs.perplexity.ai"
    "FIRECRAWL_API_KEY=your-firecrawl-key  # TODO: Get from https://firecrawl.dev"
    "YOUTUBE_API_KEY=your-youtube-key  # TODO: Get from Google Cloud Console"
    "YOUTUBE_TRANSCRIPT_LANG=en  # Language for YouTube transcripts"
)

# Essential .gitignore entries
GITIGNORE_ENTRIES=(
    ".env"
    "claude-toolkit-logs/"
)

# Colors and symbols for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_skip() {
    echo -e "${YELLOW}⏭️  $1${NC}"
}

log_install() {
    echo -e "${BLUE}📦 $1${NC}"
}

# Cleanup function
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

# OS Detection
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [[ -f /etc/os-release ]]; then
            . /etc/os-release
            case $ID in
                ubuntu|debian) echo "debian" ;;
                centos|rhel|fedora) echo "redhat" ;;
                arch) echo "arch" ;;
                *) echo "linux" ;;
            esac
        else
            echo "linux"
        fi
    else
        echo "unknown"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install with package manager (advisory only - no sudo)
install_package_advisory() {
    local package=$1
    local os=$2
    
    log_warning "$package not found. Please install it manually:"
    
    case $os in
        macos)
            echo "    brew install $package"
            ;;
        debian)
            echo "    sudo apt-get update && sudo apt-get install -y $package"
            ;;
        redhat)
            echo "    sudo dnf install -y $package"
            echo "    # or: sudo yum install -y $package"
            ;;
        arch)
            echo "    sudo pacman -S $package"
            ;;
        *)
            echo "    (Please install $package using your system's package manager)"
            ;;
    esac
    echo ""
}

# Check dependencies (no automatic installation)
check_dependencies() {
    local os=$(detect_os)
    local missing_deps=()
    
    log_info "Detected OS: $os"
    log_info "Checking system dependencies..."
    
    # Check Claude Code CLI
    if command_exists claude; then
        local claude_version=$(claude --version 2>/dev/null || echo "unknown")
        log_success "Claude Code is already installed ($claude_version)"
    else
        missing_deps+=("claude")
        log_warning "Claude Code not found. Please install it manually:"
        echo "    Visit: https://docs.anthropic.com/en/docs/claude-code/overview"
        echo "    Or download from: https://claude.ai/download"
        echo ""
    fi
    
    # Check ffmpeg
    if command_exists ffmpeg; then
        log_success "ffmpeg is already installed"
    else
        missing_deps+=("ffmpeg")
        install_package_advisory ffmpeg "$os"
    fi
    
    # Check node/npm
    if command_exists node && command_exists npm; then
        local node_version=$(node --version)
        log_success "Node.js is already installed ($node_version)"
    else
        missing_deps+=("node/npm")
        case $os in
            macos)
                log_warning "Node.js/npm not found. Please install:"
                echo "    brew install node"
                ;;
            debian)
                log_warning "Node.js/npm not found. Please install:"
                echo "    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -"
                echo "    sudo apt-get install -y nodejs"
                ;;
            *)
                log_warning "Node.js/npm not found. Please install nodejs using your package manager."
                ;;
        esac
        echo ""
    fi
    
    # Check npx (should come with npm)
    if command_exists npx; then
        log_success "npx is available"
    elif command_exists node; then
        log_warning "npx not available (but Node.js is installed - this is unusual)"
    fi
    
    # Return status based on whether we have missing dependencies
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_warning "Missing dependencies detected. The toolkit will still install, but you'll need these for full functionality:"
        for dep in "${missing_deps[@]}"; do
            echo "    - $dep"
        done
        echo ""
        log_info "You can install these dependencies later and the toolkit will work fine."
        return 1
    fi
    
    return 0
}

# Setup environment variables
setup_env_file() {
    local added_count=0
    local missing_vars=()
    
    log_info "Setting up .env file..."
    
    # Create .env if it doesn't exist
    if [[ ! -f ".env" ]]; then
        log_install "Creating new .env file"
        touch ".env"
    fi
    
    # Check and add missing environment variables
    for env_line in "${REQUIRED_ENV_VARS[@]}"; do
        local var_name=$(echo "$env_line" | cut -d'=' -f1)
        local var_line=$(echo "$env_line" | cut -d'#' -f1 | xargs)  # Remove comment for checking
        
        # Check if variable already exists in .env
        if ! grep -q "^${var_name}=" ".env" 2>/dev/null; then
            echo "$env_line" >> ".env"
            ((added_count++))
            
            # Check if it's a TODO item (placeholder value)
            if [[ "$env_line" =~ your-.*-key|your-name-here ]]; then
                missing_vars+=("$var_name")
            fi
        fi
    done
    
    if [[ $added_count -gt 0 ]]; then
        log_success "Added $added_count environment variables to .env"
    else
        log_skip "All environment variables already present in .env"
    fi
    
    # Report missing variables that need user attention
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        log_warning "User needs to configure these environment variables:"
        for var in "${missing_vars[@]}"; do
            echo "    - $var"
        done
    fi
}

# Smart merge for .gitignore
merge_gitignore() {
    local target_file=".gitignore"
    
    if [[ ! -f "$target_file" ]]; then
        log_install "Creating new .gitignore"
        printf "%s\n" "${GITIGNORE_ENTRIES[@]}" > "$target_file"
        return
    fi
    
    log_info "Merging .gitignore entries..."
    
    # Add missing entries
    local added_count=0
    for entry in "${GITIGNORE_ENTRIES[@]}"; do
        if ! grep -Fxq "$entry" "$target_file" 2>/dev/null; then
            echo "$entry" >> "$target_file"
            ((added_count++))
        fi
    done
    
    if [[ $added_count -gt 0 ]]; then
        log_success "Added $added_count new entries to .gitignore"
    else
        log_skip "All .gitignore entries already present"
    fi
}

# Backup existing file if it exists
backup_file() {
    local file=$1
    
    if [[ -e "$file" ]]; then
        if [[ "$NEEDS_BACKUP" == false ]]; then
            log_info "Creating backup directory: $BACKUP_DIR"
            mkdir -p "$BACKUP_DIR"
            NEEDS_BACKUP=true
        fi
        log_info "Backing up existing $file"
        cp -r "$file" "$BACKUP_DIR/"
        return 0
    fi
    return 1
}

# Install files with smart merging
install_files() {
    log_info "Installing Claude toolkit files..."
    
    # Handle .claude directory
    if backup_file ".claude"; then
        log_warning "Existing .claude directory found, backed up"
    fi
    log_install "Installing .claude directory..."
    cp -r "$TEMP_DIR/.claude" .
    log_success ".claude directory installed"
    
    # Handle .mcp.json
    if backup_file ".mcp.json"; then
        log_warning "Existing .mcp.json found, backed up"
    fi
    log_install "Installing .mcp.json..."
    cp "$TEMP_DIR/.mcp.json" .
    log_success ".mcp.json installed"
    
    
    # Setup environment variables
    setup_env_file
    
    # Smart .gitignore merge
    merge_gitignore
}

# Verify installation
verify_installation() {
    log_info "Verifying installation..."
    
    local errors=0
    
    # Check required files
    for file in ".claude/settings.json" ".claude/hooks" ".mcp.json" ".env"; do
        if [[ -e "$file" ]]; then
            log_success "$file installed correctly"
        else
            log_error "$file missing"
            ((errors++))
        fi
    done
    
    # Check hook files
    for hook in "user_prompt_submit.py" "pre_tool_use.py" "post_tool_use.py" "notification.py" "stop.py"; do
        if [[ -f ".claude/hooks/$hook" ]]; then
            log_success "Hook $hook installed"
        else
            log_error "Hook $hook missing"
            ((errors++))
        fi
    done
    
    return $errors
}

# Main installation function
main() {
    echo "🎭 Claude Code Toolkit Installer"
    echo "================================="
    echo ""
    
    # Safety check
    log_info "Checking current directory..."
    if [[ ! -f "package.json" && ! -f "pyproject.toml" && ! -f "Cargo.toml" && ! -f ".git/config" && ! -f "README.md" ]]; then
        log_warning "This doesn't look like a project directory."
        echo "Continue anyway? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_error "Installation cancelled"
            exit 1
        fi
    fi
    
    # Check dependencies (advisory only)
    log_info "Checking system dependencies..."
    check_dependencies  # Don't exit on missing deps
    
    # Download toolkit
    log_info "Downloading Claude toolkit..."
    if curl -L "${REPO_URL}/archive/main.tar.gz" | tar -xz -C "$TEMP_DIR" --strip-components=1; then
        log_success "Toolkit downloaded successfully"
    else
        log_error "Failed to download toolkit"
        exit 1
    fi
    
    # Install files
    install_files
    
    # Verify installation
    if verify_installation; then
        echo ""
        log_success "Installation completed successfully!"
        echo ""
        echo "📋 Next steps:"
        echo "  1. Configure your API keys in .env (see TODO comments)"
        echo "  2. Install any missing dependencies shown above"
        echo "  3. Launch Claude Code: export \$(cat .env | xargs) && claude"
        echo "  4. Try the @prime command to load project context"
        echo ""
        echo "📚 Documentation: https://github.com/Mandalorian007/claude-code-toolkit"
        
        if [[ "$NEEDS_BACKUP" == true ]]; then
            echo ""
            log_info "Previous files backed up to: $BACKUP_DIR"
        fi
    else
        log_error "Installation verification failed"
        if [[ "$NEEDS_BACKUP" == true ]]; then
            echo ""
            log_info "Your original files are backed up in: $BACKUP_DIR"
        fi
        exit 1
    fi
}

# Run main function
main "$@" 