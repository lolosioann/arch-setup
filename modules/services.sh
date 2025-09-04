#!/bin/bash

#==============================================================================
# Utility Functions
# Common helper functions used throughout the installation
#==============================================================================

# Configure system services
configure_services() {
    section "CONFIGURING SYSTEM SERVICES"
    
    local config_file="${CONFIG_DIR}/services.conf"
    
    if [[ ! -f "$config_file" ]]; then
        warning "Services config file not found: $config_file"
        warning "Skipping service configuration"
        return 0
    fi
    
    # Read services to enable
    if grep -q "^ENABLE_SERVICES=" "$config_file"; then
        local enable_services_line=$(grep "^ENABLE_SERVICES=" "$config_file")
        local enable_services_str="${enable_services_line#ENABLE_SERVICES=}"
        # Remove quotes and convert to array
        enable_services_str=$(echo "$enable_services_str" | sed 's/^"//;s/"$//')
        IFS=' ' read -ra ENABLE_SERVICES <<< "$enable_services_str"
        
        if [[ ${#ENABLE_SERVICES[@]} -gt 0 ]]; then
            enable_services "${ENABLE_SERVICES[@]}"
        fi
    fi
    
    success "Service configuration completed"
}

# Enable system services
enable_services() {
    local services=("$@")
    
    if [[ ${#services[@]} -eq 0 ]]; then
        return 0
    fi
    
    info "Enabling services: ${services[*]}"
    
    for service in "${services[@]}"; do
        if systemctl is-enabled "$service" &> /dev/null; then
            success "$service is already enabled"
        else
            info "Enabling service: $service"
            if sudo systemctl enable "$service" | tee -a "${LOG_FILE}"; then
                success "Successfully enabled $service"
                
                # Start the service if it's not running
                if ! systemctl is-active --quiet "$service"; then
                    info "Starting service: $service"
                    sudo systemctl start "$service" | tee -a "${LOG_FILE}"
                fi
            else
                error "Failed to enable $service"
            fi
        fi
    done
}

