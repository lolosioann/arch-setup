#!/bin/bash

#==============================================================================
# Package Management Functions
# Handles official repository and AUR package installation
#==============================================================================

# Install official repository packages
install_official_packages() {
    local packages=("$@")
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        warning "No official packages specified"
        return 0
    fi
    
    info "Installing official packages: ${packages[*]}"
    
    for package in "${packages[@]}"; do
        if pacman -Q "$package" &> /dev/null; then
            success "$package is already installed"
        else
            info "Installing package: $package"
            if sudo pacman -S --noconfirm "$package" | tee -a "${LOG_FILE}"; then
                success "Successfully installed $package"
            else
                error "Failed to install $package"
            fi
        fi
    done
}

# Read packages from config file and install
install_packages() {
    section "INSTALLING PACKAGES"
    
    local config_file="${CONFIG_DIR}/packages.conf"
    
    if [[ ! -f "$config_file" ]]; then
        warning "Package config file not found: $config_file"
        warning "Skipping package installation"
        return 0
    fi
    
    # Read official packages
    if grep -q "^OFFICIAL_PACKAGES=" "$config_file"; then
        local official_packages_line=$(grep "^OFFICIAL_PACKAGES=" "$config_file")
        local official_packages_str="${official_packages_line#OFFICIAL_PACKAGES=}"
        # Remove quotes and convert to array
        official_packages_str=$(echo "$official_packages_str" | sed 's/^"//;s/"$//')
        IFS=' ' read -ra OFFICIAL_PACKAGES <<< "$official_packages_str"
        
        if [[ ${#OFFICIAL_PACKAGES[@]} -gt 0 ]]; then
            info "Found ${#OFFICIAL_PACKAGES[@]} official packages to install"
            install_official_packages "${OFFICIAL_PACKAGES[@]}"
        fi
    fi
    
    # Read AUR packages
    if grep -q "^AUR_PACKAGES=" "$config_file"; then
        local aur_packages_line=$(grep "^AUR_PACKAGES=" "$config_file")
        local aur_packages_str="${aur_packages_line#AUR_PACKAGES=}"
        # Remove quotes and convert to array
        aur_packages_str=$(echo "$aur_packages_str" | sed 's/^"//;s/"$//')
        IFS=' ' read -ra AUR_PACKAGES <<< "$aur_packages_str"
        
        if [[ ${#AUR_PACKAGES[@]} -gt 0 ]]; then
            info "Found ${#AUR_PACKAGES[@]} AUR packages to install"
            install_aur_packages "${AUR_PACKAGES[@]}"
        fi
    fi
    
    success "Package installation completed"
}

# Install AUR packages
install_aur_packages() {
    local packages=("$@")
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        warning "No AUR packages specified"
        return 0
    fi
    
    info "Installing AUR packages: ${packages[*]}"
    
    for package in "${packages[@]}"; do
        if yay -Q "$package" &> /dev/null; then
            success "$package is already installed"
        else
            info "Installing AUR package: $package"
            if yay -S --noconfirm "$package" | tee -a "${LOG_FILE}"; then
                success "Successfully installed $package"
            else
                error "Failed to install $package"
            fi
        fi
    done
}

