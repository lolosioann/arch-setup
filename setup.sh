set -euo pipefail # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/config"
MODULES_DIR="${SCRIPT_DIR}/modules"
LOG_DIR="$HOME/arch_install_logs"

# Create log directory
mkdir -p "${LOG_DIR}"

# Log file with timestamp
LOG_FILE="${LOG_DIR}/install_$(date +%Y%m%d_%H%M%S).log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# LOGGING AND OUTPUT FUNCTIONS
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "${LOG_FILE}"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $*" | tee -a "${LOG_FILE}"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" | tee -a "${LOG_FILE}"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*" | tee -a "${LOG_FILE}"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" | tee -a "${LOG_FILE}"
}

section() {
    echo | tee -a "${LOG_FILE}"
    echo -e "${BLUE}===================================================${NC}" | tee -a "${LOG_FILE}"
    echo -e "${BLUE} $*${NC}" | tee -a "${LOG_FILE}"
    echo -e "${BLUE}===================================================${NC}" | tee -a "${LOG_FILE}"
}

# UTILITY FUNCTIONS
# Source all module files
source_modules() {
    for module in "${MODULES_DIR}"/*.sh; do
        if [[ -f "$module" ]]; then
            source "$module"
            info "Loaded module: $(basename "$module")"
        fi
    done
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root!"
        exit 1
    fi
}

# Check internet connection
check_internet() {
    info "Checking internet connection..."
    if ! ping -c 1 archlinux.org &> /dev/null; then
        error "No internet connection detected!"
        exit 1
    fi
    success "Internet connection verified"
}

# Update system
update_system() {
    section "UPDATING SYSTEM"
    info "Updating pacman database and system packages..."
    sudo pacman -Syu --noconfirm | tee -a "${LOG_FILE}"
    success "System updated successfully"
}

# MAIN INSTALLATION 
main() {
    log "Starting Arch Linux installation script"
    
    check_root
    check_internet
    source_modules
    update_system
    install_yay
    install_packages
    setup_dotfiles
    configure_services
    
    # Final steps
    section "INSTALLATION COMPLETE"
    success "All installation steps completed successfully!"
    info "Log file saved to: ${LOG_FILE}"
    warning "Please reboot your system to ensure all changes take effect."
}
# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
