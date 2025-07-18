#!/bin/bash

# This script automates the setup of NGINX as a reverse proxy/load balancer
# for an application running on the *same server*.
#
# IMPORTANT:
# - Run this script with sudo privileges.
# - Adjust the LOCAL_APP_PORT and NGINX_SERVER_NAME variables as needed.
# - Choose the correct OS-specific commands (apt/yum, ufw/firewalld).
# - For production, consider robust health checks, SSL, and advanced NGINX configurations.

# --- Configuration Variables ---
# Local application port (your application should be listening on this port)
LOCAL_APP_PORT="80" # Example: Your Node.js, Python, Java app listens on port 8080

# IP Address of the application server (e.g., localhost, or a Kubernetes service ClusterIP)
# The script will prompt you to confirm or change this.
APP_SERVER_IP="127.0.0.1"

# Public IP or Domain Name for the NGINX Load Balancer
# This is the address clients will use to access your server.
# Replace with your server's public IP or domain (e.g., "example.com" or "192.0.2.10")
NGINX_SERVER_NAME="1.2.3.4"

# --- Functions ---

# Function to detect OS type
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        echo "Cannot detect OS. Exiting."
        exit 1
    fi # Corrected: Was FIf, should be fi
    echo "Detected OS: $OS"
}

# Function to set up the NGINX Load Balancer/Reverse Proxy
setup_nginx_reverse_proxy() {
    echo "--- Setting up NGINX as Reverse Proxy ---"
    echo "Installing NGINX..."
    if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
        sudo apt update
        sudo apt install -y nginx
    elif [[ "$OS" == "centos" || "$OS" == "rhel" || "$OS" == "fedora" ]]; then
        sudo yum install -y nginx
        sudo systemctl enable nginx
    else
        echo "Unsupported OS for NGINX setup."
        exit 1
    fi # Corrected: Was FIf, should be fi

    sudo systemctl enable nginx
    sudo systemctl start nginx

    echo "Creating NGINX reverse proxy configuration..."

    # NGINX configuration content for a single local application
    NGINX_CONF_CONTENT="
# Define the upstream group for your local application
# NGINX will proxy requests to this address and port.
upstream local_app {
        server ${APP_SERVER_IP}:${LOCAL_APP_PORT}; # Your application running on ${APP_SERVER_IP}:${LOCAL_APP_PORT}
    # If you have multiple instances of your app running on different ports on *this same server*,
    # you could list them here for NGINX to balance between them (e.g., server 127.0.0.1:8081;).
}

# Server block for incoming HTTP requests
server {
    listen 80; # NGINX listens on port 80 for public HTTP traffic
    server_name ${NGINX_SERVER_NAME}; # The domain name or IP address NGINX will respond to

    location / {
        proxy_pass http://local_app; # Forward requests to your local application
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Optional: For HTTPS (requires SSL certificates)
    # To enable HTTPS, you'll need to:
    # 1. Obtain SSL certificates (e.g., from Let's Encrypt with Certbot).
    # 2. Uncomment and configure the 'listen 443 ssl;' block below.
    # 3. Ensure your firewall allows port 443.
    # server {
    #     listen 443 ssl;
    #     server_name ${NGINX_SERVER_NAME};

    #     ssl_certificate /etc/nginx/ssl/your_domain.crt; # Path to your certificate
    #     ssl_certificate_key /etc/nginx/ssl/your_domain.key; # Path to your private key

    #     location / {
    #         proxy_pass http://local_app;
    #         proxy_set_header Host \$host;
    #         proxy_set_header X-Real-IP \$remote_addr;
    #         proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    #         proxy_set_header X-Forwarded-Proto \$scheme;
    #     }
    # }
}
"
    if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
        echo "$NGINX_CONF_CONTENT" | sudo tee /etc/nginx/sites-available/reverse-proxy.conf > /dev/null
        echo "Enabling new site configuration and removing default..."
        sudo ln -sf /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/
        sudo rm -f /etc/nginx/sites-enabled/default
    elif [[ "$OS" == "centos" || "$OS" == "rhel" || "$OS" == "fedora" ]]; then
        # For RHEL/CentOS, it's common to put custom configs in conf.d
        echo "$NGINX_CONF_CONTENT" | sudo tee /etc/nginx/conf.d/reverse-proxy.conf > /dev/null
        # Ensure nginx.conf includes conf.d/*.conf
        if ! grep -q "include /etc/nginx/conf.d/\*.conf;" /etc/nginx/nginx.conf; then
            echo "Adding include directive to nginx.conf for conf.d..."
            sudo sed -i '/http {/a \    include /etc/nginx/conf.d/*.conf;' /etc/nginx/nginx.conf
        fi
    else
        echo "Unsupported OS for NGINX configuration."
        exit 1
    fi # Corrected: Was FIf, should be fi

    echo "Testing NGINX configuration syntax..."
    sudo nginx -t

    if [ $? -eq 0 ]; then
        echo "NGINX configuration syntax is OK. Reloading NGINX..."
        sudo systemctl reload nginx
        echo "NGINX reloaded successfully."
    else
        echo "NGINX configuration test failed. Please check the config file."
        exit 1
    fi
}

# Function to configure the firewall
configure_firewall() {
    echo "--- Configuring Firewall ---"
    if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
        echo "Using UFW..."
        sudo ufw allow 'Nginx HTTP'
        # Uncomment below if you configure HTTPS in NGINX
        # sudo ufw allow 'Nginx HTTPS'
        sudo ufw --force enable
        sudo ufw status verbose
    elif [[ "$OS" == "centos" || "$OS" == "rhel" || "$OS" == "fedora" ]]; then
        echo "Using FirewallD..."
        sudo firewall-cmd --permanent --add-service=http
        # Uncomment below if you configure HTTPS in NGINX
        # sudo firewall-cmd --permanent --add-service=https
        sudo firewall-cmd --reload
        sudo firewall-cmd --list-all
    else
        echo "Unsupported OS for firewall configuration."
        exit 1
    fi # Corrected: Was FIf, should be fi
    echo "Firewall configured."
}

# --- Main Script Execution ---
detect_os

echo "This script will set up NGINX as a reverse proxy for a local application."
echo "Your application should be running on port ${LOCAL_APP_PORT}."
echo ""
read -p "Enter the IP address of your application server [Default: ${APP_SERVER_IP}]: " userInputIP
# If the user provides an input, use it. Otherwise, keep the default.
[ -n "$userInputIP" ] && APP_SERVER_IP="$userInputIP"
echo "Using application server IP: ${APP_SERVER_IP}"
echo ""
read -p "Enter the External/Public IP address of your load balancer [Default: ${NGINX_SERVER_NAME}]: " userInputIP
# If the user provides an input, use it. Otherwise, keep the default.
[ -n "$userInputIP" ] && NGINX_SERVER_NAME="$userInputIP"
echo "Using Load Balancer IP: ${NGINX_SERVER_NAME}"

echo ""
echo "Please choose an action:"
echo "1. Setup NGINX Reverse Proxy"
echo "2. Configure Firewall"
echo "3. Run both (1 and 2)"
echo ""
read -p "Enter your choice (1, 2, or 3): " choice

case "$choice" in
    1)
        setup_nginx_reverse_proxy
        ;;
    2)
        configure_firewall
        ;;
    3)
        setup_nginx_reverse_proxy
        configure_firewall
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo "Script finished."
echo "Remember to test your setup by accessing ${NGINX_SERVER_NAME} in your browser."
echo "Ensure your application is running and listening on port ${LOCAL_APP_PORT}."
