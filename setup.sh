#!/bin/bash

############################# VARIABLES #############################

# BASH

# Bash Color
RED='\033[1;31m'        # Light Red
GREEN='\033[1;32m'      # Light Green
YELLOW='\033[1;33m'     # Yellow
PURPLE='\033[1;35m'     # Light Purple
CYAN='\033[1;36m'       # Light Cyan
NC='\033[0m'            # No Color

# Bash Text Style
BOLD=$(tput bold)       # Bold text
NORMAL=$(tput sgr0)     # Normal text

# ----------------------------------------------------------------- #

# LINUX

TIMEZONE="Asia/Jakarta"
NEW_USERNAME=""

# ----------------------------------------------------------------- #

# OTHERS

is_continue=false
FILE_SETUP="setup.sh"
FILE_TMP="_tmp.txt"

ARG_CLOUD="cloud"
ARG_DESKTOP="desktop"
ARG_DO="do"
ARG_SERVER="server"
ARG_VBOX="vbox"

################################ MAIN ###############################

main() {

    # ./setup.sh

    if [ "$0" == "./$FILE_SETUP" ] && [ "$1" == "" ] && [ "$2" == "" ]; then

        is_sudo_user
        if [ "$is_continue" = true ]; then ask_user_option; fi
    
    
    # ./setup.sh vbox desktop

    elif [ "$0" == "./$FILE_SETUP" ] && [ "$1" == "$ARG_VBOX" ] && [ "$2" == "$ARG_DESKTOP" ]; then

        is_sudo_user
        if [ "$is_continue" = true ]; then setup_vbox_desktop; fi
    

    # ./setup.sh vbox server

    elif [ "$0" == "./$FILE_SETUP" ] && [ "$1" == "$ARG_VBOX" ] && [ "$2" == "$ARG_SERVER" ]; then

        is_sudo_user
        if [ "$is_continue" = true ]; then setup_vbox_server; fi


    # ./setup.sh cloud do

    elif [ "$0" == "./$FILE_SETUP" ] && [ "$1" == "$ARG_CLOUD" ] && [ "$2" == "$ARG_DO" ]; then

        is_sudo_user
        if [ "$is_continue" = true ]; then setup_cloud_digitalocean; fi


    # If the command is not valid, an error message will be shown

    else

        TEMP_PRINT="ERROR: Command is not valid"
        printf "${RED}${TEMP_PRINT}...${NC}\n"
        
        exit

    fi

}

############################## FUNCTIONS ############################

# ============================== START ==============================

# Check if User is in sudo mode
is_sudo_user() {
    
    if [ `whoami` != root ]; then
    
        TEMP_PRINT="ERROR: Please run this script as root or using sudo"
        printf "${RED}${TEMP_PRINT}...${NC}\n"
        
        exit

    else
    
        is_continue=true
        
    fi

}


# Ask the user option
ask_user_option() {

    ask_user() {

        printf "Which type?\n  1. VBox (Desktop)\n  2. VBox (Server)\n  3. Cloud (DigitalOcean)\n"
        read -p "Option: " user_option

        if [ "$user_option" == "1" ]; then

            setup_vbox_desktop

        elif [ "$user_option" == "2" ]; then

            setup_vbox_server

        elif [ "$user_option" == "3" ]; then

            setup_cloud_digitalocean

        else

            TEMP_PRINT="ERROR: Wrong option"
            printf "${RED}${TEMP_PRINT}...${NC}\n"

        fi

    }

    ask_user

    while [ "$user_option" != "1" ] && [ "$user_option" != "2" ] && [ "$user_option" != "3" ]; do
        ask_user
    done

}


# -------------------------------------------------------------------

# Setup for desktop
setup_vbox_desktop() {

    TEMP_PRINT="Setup for desktop"
    printf "${YELLOW}${TEMP_PRINT}...${NC}\n"

    # Init Setup
    init_setup

    # Install Required Apps
    install_dev_tools
    install_other_apps
    
    # End Setup
    end_setup

}


# Setup for server
setup_vbox_server() {

    TEMP_PRINT="Setup for server"
    printf "${YELLOW}${TEMP_PRINT}...${NC}\n"

    # Init Setup
    init_setup

    # Install Required Apps
    install_other_apps

    # End Setup
    end_setup

}


# Setup for DigitalOcean
setup_cloud_digitalocean() {

    TEMP_PRINT="Setup for server"
    printf "${YELLOW}${TEMP_PRINT}...${NC}\n"

    # Init Setup
    create_user
    init_setup

    # Install Required Apps
    install_other_apps

    # End Setup
    end_setup

}


# -------------------------------------------------------------------

# Create User
create_user() {

    # Create sudo user
    create_sudo_user

    # Copy SSH authorized keys
    copy_ssh_authorized_keys

}


# Init Setup 
init_setup() {

    # Set timezone
    set_timezone

    # Update/upgrade packages
    update_and_upgrade

}


# End Setup
end_setup() {

    # Enable the firewall
    enable_firewall

    # Reboot the system 
    reboot_system       

}


# Install developing apps
install_dev_tools() {

    # Essential
    install_vscode            # Install Visual Studio Code
    install_sqlitebrowser     # Install SQLite Browser
    install_mysqlworkbench    # Install MySQL Workbench
    install_postman           # Install Postman

    # Additional
    install_filezilla         # Install FileZilla
    install_tree              # Install tree
    install_rename            # Install rename
    install_imagemagick       # Install Imagemagick

}


# Install other apps
install_other_apps() {

    install_openssh                 # Install OpenSSH
    install_htop                    # Install htop
    install_nettools                # Install net-tools
    install_git                     # Install Git
    install_python_dependencies     # Install Python dependencies
    install_docker                  # Install Docker
    install_nginx                   # Install NGINX
    install_certbot                 # Install Certbot
    install_redis                   # Install Redis

}


# ============================== INIT ================================

# Create sudo user
create_sudo_user() {

    temp="Create sudo user"
    printf "${CYAN}${temp}:${NC}\n"

    is_continue=false

    while [ $is_continue = false ]; do

        # Check new username
        read -p "Enter username: " NEW_USERNAME

        # Check if user exist
        is_user_exist

    done

    # Create the user
    sudo adduser $NEW_USERNAME
    # Add to sudo group
    sudo usermod -aG sudo $NEW_USERNAME

}


# Check if user exist
is_user_exist() {

    id -u "$NEW_USERNAME" &> $FILE_TMP
    temp1=$(cat $FILE_TMP | grep id)

    if [ "$temp1" == "" ]; then

        temp="User \"$NEW_USERNAME\" is exist"
        printf "${RED}${temp}!${NC}\n"

        is_continue=false  
        
    else

        is_continue=true
          
    fi

    rm $FILE_TMP

}


# Copy SSH authorized keys
copy_ssh_authorized_keys() {

    temp="Copy SSH authorized keys"
    printf "${CYAN}${temp}:${NC}\n"

    mkdir /home/$NEW_USERNAME/.ssh
    cp /root/.ssh/authorized_keys /home/$NEW_USERNAME/.ssh/
    chown -R $NEW_USERNAME:$NEW_USERNAME /home/$NEW_USERNAME/.ssh/

    printf "${temp}...${NC} ${GREEN}OK${NC}\n"

}


# Set timezone
set_timezone() {

    TEMP_PRINT="Set timezone"
    printf "${CYAN}${TEMP_PRINT}:${NC}\n"
    
    timedatectl set-timezone $TIMEZONE

    printf "${TEMP_PRINT}...${NC} ${GREEN}OK${NC}\n"

}


# Update and upgrade the packages 
update_and_upgrade() {

    TEMP_PRINT="Update and upgrade the packages"
    printf "${CYAN}${TEMP_PRINT}:${NC}\n"

    # Update the package lists that need upgrading
    TEMP_PRINT="Update the package lists that need upgrading"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"

    sudo apt update

    # Upgrade packages and its dependencies
    TEMP_PRINT="Upgrade packages and its dependencies"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"

    sudo apt dist-upgrade -y

}


# ============================ DEV-TOOLS =============================

# Install Visual Studio Code
install_vscode() {

    TEMP_PRINT="Install Visual Studio Code"
    printf "${CYAN}${TEMP_PRINT}:${NC}\n"

    # Install the dependencies
    TEMP_PRINT="Install the dependencies"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"

    sudo apt install software-properties-common apt-transport-https wget -y
    
    # Import the Microsoft GPG key
    TEMP_PRINT="Import the Microsoft GPG key"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"

    wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
    
    # Enable the repository and update the package index
    TEMP_PRINT="Enable the repository and update the package index"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"

    sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
    sudo apt update

    # Install the package
    TEMP_PRINT="Install the package"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"

    sudo apt install code -y

}


# Install SQLite Browser
install_sqlitebrowser() {

    # https://sqlitebrowser.org/dl/

    TEMP_PRINT="Install SQLite Browser"
    printf "${CYAN}${TEMP_PRINT}:${NC}\n"

    sudo apt install sqlitebrowser -y
 
}


# Install MySQL Workbench
install_mysqlworkbench() {

    TEMP_PRINT="Install MySQL Workbench"
    printf "${CYAN}${TEMP_PRINT}:${NC}\n"

    # Install the dependencies of MySQL Workbench
    TEMP_PRINT="Install the dependencies of MySQL Workbench"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"

    sudo apt install libopengl0 libpcrecpp0v5 libproj15 libzip5 -y
    
    # Download the installer
    TEMP_PRINT="Download the installer"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"

    wget https://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-workbench-community_8.0.26-1ubuntu20.04_amd64.deb
    
    # Install the MySQL Workbench
    TEMP_PRINT="Install the MySQL Workbench"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"

    sudo dpkg -i mysql-*
    
    # Remove the installer after installation finish
    TEMP_PRINT="Remove the installer after installation finish"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"

    rm mysql-*

}


# Install Postman
install_postman() {

    # https://speedysense.com/install-postman-on-ubuntu-20-04/

    TEMP_PRINT="Install Postman"
    printf "${CYAN}${TEMP_PRINT}:${NC}\n"

    # Download the installer
    TEMP_PRINT="Download the installer"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"

    wget --content-disposition https://dl.pstmn.io/download/latest/linux
    
    # Extract package
    TEMP_PRINT="Extract package"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"

    tar -xzf Postman-linux-*
    
    # Move the directory to `opt/` directory
    TEMP_PRINT="Move the directory to \`opt/\` directory"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"

    sudo mv Postman /opt
    
    # Create a Symbolic Links
    TEMP_PRINT="Create a Symbolic Links"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"

    sudo ln -s /opt/Postman/Postman /usr/local/bin/postman
    
    # Create a desktop file for the app
    TEMP_PRINT="Create a desktop file for the app"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"

    DESKTOP_FILE="/usr/share/applications/postman.desktop"
    echo "[Desktop Entry]" >> $DESKTOP_FILE
    echo "Type=Application" >> $DESKTOP_FILE
    echo "Name=Postman" >> $DESKTOP_FILE
    echo "Icon=/opt/Postman/app/resources/app/assets/icon.png" >> $DESKTOP_FILE
    echo "Exec=\"/opt/Postman/Postman\"" >> $DESKTOP_FILE
    echo "Comment=Postman GUI" >> $DESKTOP_FILE
    echo "Categories=Development;Code;" >> $DESKTOP_FILE
    
    # Remove the installer after installation finish
    TEMP_PRINT="Remove the installer after installation finish"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"

    rm Postman-linux-*

}


# ============================= OTHERS ===============================


# Install OpenSSH
install_openssh() {

    TEMP_PRINT="Install OpenSSH"
    printf "${CYAN}${TEMP_PRINT}:${NC}\n"

    sudo apt install openssh-server -y

}


# Install htop
install_htop() {

    TEMP_PRINT="Install htop"
    printf "${CYAN}${TEMP_PRINT}:${NC}\n"

    sudo apt install htop -y

}


# Install net-tools
install_nettools() {

    TEMP_PRINT="Install net-tools"
    printf "${CYAN}${TEMP_PRINT}:${NC}\n"

    sudo apt install net-tools -y

}

# Install tree
install_tree() {

    TEMP_PRINT="Install tree"
    printf "${CYAN}${TEMP_PRINT}:${NC}\n"

    sudo apt install tree -y

}


# Install rename
install_rename() {

    TEMP_PRINT="Install rename"
    printf "${CYAN}${TEMP_PRINT}:${NC}\n"

    sudo apt install rename -y

}


# Install Imagemagick
install_imagemagick() {

    TEMP_PRINT="Install Imagemagick"
    printf "${CYAN}${TEMP_PRINT}:${NC}\n"

    sudo apt install imagemagick -y

}


# Install FileZilla
install_filezilla() {

    TEMP_PRINT="Install FileZilla"
    printf "${CYAN}${TEMP_PRINT}:${NC}\n"

    sudo apt install filezilla -y

}


# Install Git
install_git() {

    TEMP_PRINT="Install Git"
    printf "${CYAN}${TEMP_PRINT}:${NC}\n"

    sudo apt install git -y

}


# Install Python dependencies
install_python_dependencies() {

    TEMP_PRINT="Install Python dependencies"
    printf "${CYAN}${TEMP_PRINT}:${NC}\n"

    # Install Python environment
    TEMP_PRINT="Install Python environment"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"
    
    sudo apt install python3.8-venv -y
    
    # Install PIP
    TEMP_PRINT="Install PIP"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"
    
    sudo apt install python3-pip -y
    
    # Install Django Admin
    TEMP_PRINT="Install Django Admin"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"
    
    sudo apt install python3-django -y

}


# Install Docker
install_docker() {

    TEMP_PRINT="Install Docker"
    printf "${CYAN}${TEMP_PRINT}:${NC}\n"

    # Install the dependencies of Docker
    TEMP_PRINT="Install the dependencies of Docker"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"
    
    sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release -y
    
    # Add Docker’s official GPG key
    TEMP_PRINT="Add Docker’s official GPG key"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"
    
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Set up the stable repository of Docker and update the package index
    TEMP_PRINT="Set up the stable repository of Docker and update the package index"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"
    
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update

    # Install the latest version of Docker Engine and container
    TEMP_PRINT="Install the latest version of Docker Engine and container"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"
    
    sudo apt install docker-ce docker-ce-cli containerd.io -y
    
    # Install Docker Compose
    TEMP_PRINT="Install Docker Compose"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"
    
    sudo apt install docker-compose -y
    
    # Adding user to the Docker group
    TEMP_PRINT="Adding user to the Docker group"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"
    
    sudo usermod -a -G docker $USER
    
}


# Install NGINX
install_nginx() {

    TEMP_PRINT="Install NGINX"
    printf "${CYAN}${TEMP_PRINT}:${NC}\n"

    sudo apt install nginx -y

}


# Install Certbot and it’s NGINX plugin
install_certbot() {

    TEMP_PRINT="Install Certbot and it’s NGINX plugin"
    printf "${CYAN}${TEMP_PRINT}:${NC}\n"

    sudo apt install certbot python3-certbot-nginx -y

}


# Install Redis
install_redis() {

    TEMP_PRINT="Install Redis"
    printf "${CYAN}${TEMP_PRINT}:${NC}\n"

    sudo apt install redis-server -y

}
    

# Enable the firewall
enable_firewall() {

    TEMP_PRINT="Enable the firewall"
    printf "${CYAN}${TEMP_PRINT}:${NC}\n"

    # Enable the Uncomplicated Firewall (UFW)
    TEMP_PRINT="Enable the Uncomplicated Firewall (UFW)"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"

    sudo ufw enable
    
    # Allow OpenSSH
    TEMP_PRINT="Allow OpenSSH"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"

    sudo ufw allow OpenSSH
    
    # Allow NGINX
    TEMP_PRINT="Allow NGINX"
    printf "${PURPLE}${TEMP_PRINT}...${NC}\n"

    sudo ufw allow 'Nginx Full'

}


# Reboot the system
reboot_system() {

    # Some settings or installation need reboot to be affected.

    TEMP_PRINT="Reboot the system"
    printf "${CYAN}${TEMP_PRINT}:${NC}\n"

    # Ask the user
    read -p "Reboot now? [y/N] " is_reboot

    if [ "$is_reboot" == "y" ] || [ "$is_reboot" == "Y" ]; then

        printf "${TEMP_PRINT}...${NC} ${GREEN}OK${NC}\n"
        sudo reboot now
    else

        TEMP_PRINT="Reboot the system canceled."
        printf "${RED}${TEMP_PRINT}${NC}\n"

        exit

    fi

}


main "$@"


############################## REFERENCES ############################
# - How to change the output color of echo in Linux https://stackoverflow.com/a/5947802
# - How to fix ERROR: Couldn’t connect to Docker daemon at http+docker://localhost – is it running? https://techoverflow.net/2019/03/16/how-to-fix-error-couldnt-connect-to-docker-daemon-at-httpdocker-localhost-is-it-running/
# - What does "sudo apt-get update" do? https://askubuntu.com/a/222352
# - Check Whether a User Exists https://stackoverflow.com/a/14811915