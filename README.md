# Arch Linux Installation Script

A modular bash script to automate Arch Linux installation tasks i need

## Project Structure

```
arch-setup/
├── setup.sh              # Main setup script
├── config/
│   ├── packages.conf       # Package definitions
│   ├── services.conf       # Services to enable
│   └── settings.conf       # General settings (dotfiles repo, etc.)
├── modules/
│   ├── aur.sh             # AUR helper (yay) installation
│   ├── packages.sh        # Package installation functions
│   ├── dotfiles.sh        # Dotfiles cloning and setup
│   └── services.sh        # Enable services
├── logs/                  # Installation logs
└── README.md
```

## Quick Start

> [!CAUTION] Always test this script in a virtual machine before running on your main system!

1. **Download**:

   ```bash
   git clone https://github.com/lolosioann/arch-setup
   cd arch-setup
   chmod +x setup.sh
   ```

2. **Configure Your Settings**:
   - Edit `config/settings.conf` and set your dotfiles repository URL
   - Customize `config/packages.conf` with your desired packages
   - Modify `config/services.conf` for services you want enabled/disabled

3. **Run Installation**:
   ```bash
   ./setup.sh
   ```

## Installation Process

The script follows this sequence:

1. **Pre-flight Checks**: Verify internet connection, user permissions
2. **System Update**: Update pacman database and system packages
3. **AUR Helper**: Install and configure yay
4. **Package Installation**: Install packages from official repos and AUR
5. **Dotfiles Setup**: Clone and configure your dotfiles
6. **Service Configuration**: Enable specified services

## Dotfiles Integration

The script installs dotfiles directly into the .config directory.
The following features exist:

- **Automatic Setup Scripts**: Runs `install.sh`, `setup.sh`, or `make install`
- **Backup Protection**: Backs up existing configurations before replacing

## Logging

All operations are logged to `logs/install_YYYYMMDD_HHMMSS.log` with:

- Timestamps for each operation
- Success/failure status
- Error messages and debugging information
- Complete command output

## Safety Features

- **Root Check**: Prevents running as root user
- **Backup Creation**: Backs up existing configurations
- **Internet Verification**: Ensures connectivity before proceeding
- **Package Verification**: Checks if packages are already installed
- **Service Status Check**: Verifies service states before modification
