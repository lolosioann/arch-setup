#!/bin/bash

#==============================================================================
# Dotfiles Management Functions
# Handles cloning and setting up dotfiles from GitHub
#==============================================================================

# Setup dotfiles from GitHub repository
setup_dotfiles() {
    section "SETTING UP DOTFILES"
    
    local config_file="${CONFIG_DIR}/settings.conf"
    local dotfiles_repo=""
    local dotfiles_branch="main"
    local dotfiles_dir=$XDG_CONFIG_HOME
    
    # Read configuration
    if [[ -f "$config_file" ]]; then
        source "$config_file"
    else
        error "Settings config file not found: $config_file"
        error "Please create the config file with DOTFILES_REPO variable"
        return 1
    fi
    
    if [[ -z "$DOTFILES_REPO" ]]; then
        error "DOTFILES_REPO not specified in settings.conf"
        return 1
    fi
    
    dotfiles_repo="$DOTFILES_REPO"
    [[ -n "${DOTFILES_BRANCH:-}" ]] && dotfiles_branch="$DOTFILES_BRANCH"
    [[ -n "${DOTFILES_DIR:-}" ]] && dotfiles_dir="$DOTFILES_DIR"
    
    info "Dotfiles repository: $dotfiles_repo"
    info "Branch: $dotfiles_branch"
    info "Target directory: $dotfiles_dir"
    
    # Backup existing dotfiles if directory exists
    if [[ -d "$dotfiles_dir" ]]; then
        warning "Dotfiles directory already exists"
        local backup_dir="${dotfiles_dir}.bak.$(date +%Y%m%d_%H%M%S)"
        info "Creating backup: $backup_dir"
        mv "$dotfiles_dir" "$backup_dir"
    fi
    
    # Clone dotfiles repository
    info "Cloning dotfiles repository..."
    mkdir $dotfiles_dir && cd $dotfiles_dir
    git init
    if git remote add origin -b "$dotfiles_branch" "$dotfiles_repo" | tee -a "${LOG_FILE}"; then
        info "Origin setup successfully"
    fi
    if git pull | tee -a "${LOG_FILE}"; then
        success "Dotfiles cloned successfully"
    else
        error "Failed to clone dotfiles repository"
        return 1
    fi
    
    # Check for and run setup script
    if [[ -x "./install.sh" ]]; then
        info "Found install script, executing..."
        ./install.sh | tee -a "${LOG_FILE}"
    elif [[ -x "./setup.sh" ]]; then
        info "Found setup script, executing..."
        ./setup.sh | tee -a "${LOG_FILE}"
    elif [[ -f "./Makefile" ]]; then
        info "Found Makefile, running make install..."
        make install | tee -a "${LOG_FILE}"
    else
        warning "No setup script found in dotfiles repository"
        info "You may need to manually configure your dotfiles"
    fi
    
    success "Dotfiles setup completed"
    
    # Return to original directory
    cd "$SCRIPT_DIR"
}

