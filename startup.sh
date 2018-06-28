#! /bin/bash

sudo apt-get remove docker docker-engine docker.io
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    htop \
    unzip

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
sudo apt-get update
sudo apt-get install docker-ce -y

sudo groupadd docker
sudo usermod -aG docker $USER

sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

#Then logout and back in and run the commands below
#docker-compose --version
#docker run hello-world
#git clone https://github.com/schmidtmj/geonode.git
#cd geonode
#git pull
#echo GOOGLE_API_KEY="AIzaSyArknDsx5staqJC7ZVcFugOOWGbdpDyGQA" | ./scripts/docker/env/production/django.env
#echo BING_API_KEY="AiqISIdC-cHcD89CrteTT8DmOVWMCacFDiuVklbHHeobNruh10g3d7X9avgQbffH" | ./scripts/docker/env/production/django.env

#docker-compose up
