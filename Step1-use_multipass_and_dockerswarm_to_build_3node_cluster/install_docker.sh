# Set up the repository
## 1. Update the apt package index and install packages to allow apt to use a repository over HTTPS:
sudo apt-get update

## 2. Add Docker’s official GPG key:
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

## 3. Use the following command to set up the repository:
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Restart docker
sudo service docker stop && sudo service docker start

sudo usermod -aG docker $USER