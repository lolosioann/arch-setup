#!/bin/bash

#==============================================================================
# AUR Helper Functions
# Handles yay installation and AUR package management
#==============================================================================

# Install yay AUR helper
install_yay() {
    section "INSTALLING YAY AUR HELPER"
    
    if command -v yay &> /dev/null; then
        success "yay is already installed"
        return 0
    fi
    
    info "Installing yay AUR helper..."
    
    # Install git and base-devel if not present
    sudo pacman -S --needed --noconfirm git base-devel | tee -a "${LOG_FILE}"
    
    # Create temporary directory
    local temp_dir="/tmp/yay-install"
    rm -rf "${temp_dir}"
    mkdir -p "${temp_dir}"
    
    # Clone and install yay
    cd "${temp_dir}"
    git clone https://aur.archlinux.org/yay.git | tee -a "${LOG_FILE}"
    cd yay
    makepkg -si --noconfirm | tee -a "${LOG_FILE}"
    
    # Cleanup
    rm -rf "${temp_dir}"
    
    if command -v yay &> /dev/null; then
        success "yay installed successfully"
    else
        error "Failed to install yay"
        exit 1
    fi
}

