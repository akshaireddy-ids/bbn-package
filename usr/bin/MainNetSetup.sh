#!/bin/bash


# update_progress "Welcome"
# Welcome message and checkbox
zenity --text-info --title="Welcome to Bharat Blockchain Network" --html --url="https://i.ibb.co/v3QHGn5/bbn-about.png" --checkbox="Are you ready to set up a Node?" --width=1000 --height=500


# Check the user's response
if [ $? -ne 0 ]; then
    zenity --info --text="Setup canceled. Exiting." --title="Setup Canceled" --width=300
    exit 1
fi


# Function to display a progress bar with message
show_progress() {
    (
        # echo "# Cloning repository..."; sleep 2
        # echo "10"; sleep 1
        echo "# Installing dependencies..."; sleep 2
        echo "30"; sleep 1
        echo "# Configuring settings..."; sleep 1
        echo "60"; sleep 1
        echo "# Configuring settings..."; sleep 1
        echo "90"; sleep 1
        echo "# Finalizing installation..."; sleep 2
        echo "100"; sleep 1
    ) | zenity --progress \
        --title="Installation Progress" \
        --text="Please wait..." \
        --percentage=0 \
        --auto-close \
        --width=300
}
# Function to display a message box
show_message() {
    zenity --info --text="$1" --title="$2" --width=300 --height=100
}

# Function to display a password dialog
ask_password() {
     password=$(zenity --password --title="Enter Your Sudo Password" --width=300 --text="Please enter your sudo password:")

     # Check the user's response
    if [ $? -ne 0 ]; then
    zenity --info --text="Setup canceled. Exiting." --title="Setup Canceled" --width=300
    exit 1
    fi

    # Use sudo to check if the password is correct
    if ! echo "$password" | sudo -S true; then
        zenity --error --text="Incorrect password. Please try again." --width=300
        ask_password
    fi
}

# Check system requirements
check_requirements() {
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        show_message "Please run the script without root privileges." "Requirements Check"
        exit 1
    fi

    # Check internet connectivity
    if ! ping -c 1 google.com &>/dev/null; then
        show_message "No internet connectivity. Please check your network connection." "Requirements Check"
        exit 1
    fi

    # Check available RAM (minimum 8GB)
    available_ram=$(free -g | awk '/^Mem:/{print $2}')
    if ((available_ram < 7)); then
        show_message "Insufficient RAM. Minimum 8GB RAM is required." "Requirements Check"
        exit 1
    fi


    # Check available storage space (minimum 100GB)
    available_storage=$(df -B1 --output=avail / | tail -n1 | tr -d '[:space:]')
    required_space=$((100 * 1024 * 1024 * 1024))  # 100GB in bytes

    if ((available_storage < required_space)); then
        show_message "Insufficient storage space. Minimum 100GB storage space is required." "Requirements Check"
        exit 1
    fi

     # Check if port 9545 is enabled
    if ! nc -z localhost 9545; then
        zenity --info --text="Port 9545 is not enabled. This port is required for communication with the Bharat Blockchain Network. Enabling port 9545 to establish the necessary connections." --title="Port 9545 Enablement"
        echo "$password" | sudo -S ufw allow 9545
        show_message "Port 9545 has been enabled." "Requirements Check"
    else
        show_message "Port 9545 is already enabled." "Requirements Check"
    fi

    # Check the user's response
    if [ $? -ne 0 ]; then
    zenity --info --text="Setup canceled. Exiting." --title="Setup Canceled" --width=300
    exit 1
    fi

}

# Function to handle Ctrl+C interrupt
interrupt_handler() {
    show_message "Installation interrupted by user." "Installation Interrupted"
    exit 1
}

# Set the interrupt handler
trap interrupt_handler SIGINT

# Function to update progress
update_progress() {
    echo "$1" >&3
}

# Create the progress pipe
pipe="/tmp/progress_pipe"
mkfifo "$pipe"
exec 3<>$pipe


# Start the progress dialog
zenity --progress --title="Setting up the MainNet..." --width=1200 --height=600 --percentage=0  < $pipe &

# Inform the user about installations
zenity --info --text="This script will install the following dependencies:\n\n- Git\n- cURL\n- Docker\n- Docker Compose\n\nPlease click 'OK' to proceed with the installation." --title="Dependency Installation" --width=400


# Check the user's response
if [ $? -ne 0 ]; then
    zenity --info --text="Setup canceled. Exiting." --title="Setup Canceled" --width=300
    exit 1
fi

# Ask for sudo password
# password=$(ask_password)
ask_password


# Check the user's response
if [ $? -ne 0 ]; then
    zenity --info --text="Setup canceled. Exiting." --title="Setup Canceled" --width=300
    exit 1
fi

# Check system requirements
check_requirements

# Check if Git is installed
if ! [ -x "$(command -v git)" ]; then

# Message explaining git installation
zenity --question --text="Git is not installed. Do you want to install it?"

# Check the user's response
if [ $? -ne 0 ]; then
    zenity --info --text="Git installation canceled. Exiting." --title="Setup Canceled" --width=300
    exit 1
fi

    if [ $? -eq 0 ]; then
        # show_message "Installing Git..." "Installing Git"
        echo "$password" | sudo -S apt-get update
        show_progress
        echo "$password" | sudo -S apt-get install -y git
    else
        show_message "Git installation skipped." "Git Installation"
    fi
else
    show_message "Git is already installed." "Git Installation"
fi

update_progress "15" "Git Installation"



# Check if cURL is installed
if ! [ -x "$(command -v curl)" ]; then
    # # Ask for cURL installation confirmation
    zenity --question --text="cURL is not installed. Do you want to install it?"

# Check the user's response
if [ $? -ne 0 ]; then
    zenity --info --text="cURL installation canceled. Exiting." --title="Setup Canceled" --width=300
    exit 1
fi

    if [ $? -eq 0 ]; then
        # show_message "Installing cURL..." "Installing cURL"
        echo "$password" | sudo -S apt-get update
        show_progress
        echo "$password" | sudo -S apt-get install -y curl
    else
        show_message "cURL installation skipped." "cURL Installation"
    fi
else
    show_message "cURL is already installed." "cURL Installation"
fi

update_progress "20" "cURL Installation"

# Function to install Docker
install_docker() {
    # Check if Docker is already installed
    if [ -x "$(command -v docker)" ]; then
        show_message "Docker is already installed. Skipping installation." "Docker Installation"
        return
    fi

    # Ask for Docker installation confirmation
    zenity --question --text="Docker is not installed. Do you want to install it?"

    # Check the user's response
    local confirmation_result=$?
    if [ $confirmation_result -eq 0 ]; then
        # show_message "Installing Docker..." "Installing Docker"
        echo "$password" | sudo -S apt update
        echo "$password" | sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "$password" | echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        echo "$password" | sudo -S apt update
        show_progress
        echo "$password" | sudo apt install -y docker-ce docker-ce-cli containerd.io
    else
        zenity --info --text="Docker installation canceled. Exiting." --title="Setup Canceled" --width=300
        exit 1
    fi
}

# Call the function to install Docker
install_docker

# Check if Docker installation was successful
if ! [ -x "$(command -v docker)" ]; then
    zenity --error --text="Docker installation failed. Please check your internet connection and try again." --title="Setup Error" --width=300
    exit 1
fi

# Add the current user to the Docker group
echo "$password" | sudo -S usermod -aG docker $USER
echo "$password" | sudo -S setfacl --modify user:$USER:rw /var/run/docker.sock

sleep 3

update_progress "35" "Docker Installation"

# Check if Docker Compose is installed
# zenity --info --text="Docker Compose is being installed because it is will help in Orchestrate Services, Environment Configuration, Networking, Volume Management" --title="Docker Compose Installation" --width=400

# Check the user's response
if [ $? -ne 0 ]; then
    zenity --info --text="Docker-Compose installation canceled. Exiting." --title="Setup Canceled" --width=300
    exit 1
fi

if ! [ -x "$(command -v docker-compose)" ]; then
    # Ask for Docker Compose installation confirmation
    zenity --question --text="Docker Compose is not installed. Do you want to install it?"

    # Check the user's response
    if [ $? -eq 0 ]; then
        # show_message "Installing Docker Compose..." "Installing Docker Compose"
        echo "$password" | sudo -S curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

        # Check if the download and installation were successful
        if [ $? -eq 0 ]; then
            echo "$password" | sudo -S chmod +x /usr/local/bin/docker-compose
            show_progress
        else
            zenity --error --text="Docker Compose installation failed. Please check your internet connection and try again." --title="Setup Error" --width=300
            exit 1
        fi
    else
        zenity --info --text="Docker Compose installation skipped." --title="Docker Compose Installation"
    fi
else
    show_message "Docker Compose is already installed." "Docker Compose Installation"
fi


update_progress "50" "Docker Compose Installation"

# # Docker login function with fixed username and password prompt
# docker_login() {
#     docker_username="idscloudadmin"

#     while true; do
#         docker_password=$(zenity --password --title="Docker Login" --text="Enter your Docker Hub password:" --width=300)

#         if [ $? -ne 0 ]; then
#             zenity --info --text="Docker login canceled. Exiting." --title="Setup Canceled" --width=300
#             exit 1
#         fi

#         echo "$docker_password" | docker login --username "$docker_username" --password-stdin
#         if [ $? -ne 0 ]; then
#             zenity --error --text="Docker login failed. Please check your credentials and try again." --title="Docker Login Failed" --width=300
#         else
#             zenity --info --text="Docker login successful!" --title="Docker Login" --width=300
#             break
#         fi
#     done
# }

# # Call the Docker login function after prerequisites installation
# docker_login



# Display completion message
show_message "Prerequisites installation completed." "Setup Completed"


sleep 1
# Step 3: Check for Existing Nodes
zenity --info --text="Checking for Existing Nodes" --title="Setup in Progress" --width=300
echo "Searching for a healthy container..."

docker_ps=$(docker ps -a)
  healthy_container=$(echo "$docker_ps" | grep "health" | awk '{print $1}')

  if [ -n "$healthy_container" ]; then
    echo "Healthy container found: $healthy_container"
    response=$(zenity --question --title="BBN Network Detected" --text="Do you want to upgrade the BBN Network?"; echo $?)
    echo $response
    if [ "$response" = "1" ]; then
    echo "User clicked No."
    sleep 1
    zenity --info --width 300 --text "Upgrade Cancelled. Click OK to close the window."
    sleep 1
    exit 
    else 
    echo "Continue"
    fi
   else
  echo "No healthy containers found."
fi

sleep 2

# Create the destination directory
DESTINATION="$PWD/BBN-Mainnet-Node"
mkdir -p "$DESTINATION"
cd "$DESTINATION"


# Copy packaged files to the destination directory
PACKAGE_DIR="/usr/add-bbn-node-mainnet"
cp -r "$PACKAGE_DIR"/* "$DESTINATION"


# Stop and remove existing containers and volumes

# zenity --info --text="Stopping Existing Containers and Volumes" --title="Setup in Progress" --width=300

# Ask for sudo password
# password=$(ask_password)
ask_password


# cd volumes
# PASSWD=$(zenity --password --title="Enter Your System Password") 
# echo -e "$PASSWD" | sudo -S rm -rf writers
# # rm -rf writers
# # cd ..
# update_progress "60"
# echo "Running command: docker-compose down"
# docker-compose down
# docker stop "$(docker ps -aq)"
# docker rm "$(docker ps -aq)"
# docker volume rm "$(docker volume ls -q)" -f
# docker system prune -f

sleep 3
# Start the containers
update_progress "60"
# echo "Running command: docker-compose up -d"
# docker-compose up -d
if [ -d "./volumes/writers" ]; then
  echo "The writers folder already exists. Skipping the generator container."
  # Run Docker Compose without the generator service
  docker compose up mainnet-node1
else
  echo "The writers folder does not exist. Running all services."
  # Run Docker Compose with all services
  docker compose build
  docker compose up -d
fi 


# zenity --info --title="Docker Container have been started" --text="Docker Network and Container are  running"
echo "Docker Network and Container are  running"
# Check the user's response
if [ $? -ne 0 ]; then
    zenity --info --text="Node Installation canceled. Exiting." --title="Setup Canceled" --width=300
    exit 1
fi

sleep 3
# Check for a healthy container
update_progress "70"
echo "Searching for a healthy container..."
while true; do
  docker_ps=$(docker ps -a)
  healthy_container=$(echo "$docker_ps" | grep "health" | awk '{print $1}')
  if [ -n "$healthy_container" ]; then
    echo "Healthy container found: $healthy_container"
    break
  fi
  sleep 1
done

# Get the node address
update_progress "80"
echo "Alternative way to get the node address: $PWD/volumes/writers/1/keys/key.pub"
nodeId=$(cat "$PWD/volumes/writers/1/keys/key.pub")

zenity --text-info --title="Node Setup Completed" --html --filename=<(echo -e "<html><body><h1>Node setup has been completed, Node ID is: $nodeId</h1><p>Make sure to copy NodeId and submit on BBN Portal.</p></body></html>") --checkbox="Did you copy Node ID?" --width=1000 --height=500

echo "Node Address: $nodeId"

sleep 1
# Stop the generator container
update_progress "90"

# Display a completion message
update_progress "100"
zenity --info --width 300 --text "Setup completed. Click OK to close." --title="Setup Completed"

# show_message "Node"
exec 3>&-
rm -f "$pipe"
