#!/bin/bash

# Update the package database
sudo yum update -y

# Install Git
sudo yum install git -y

# Install Docker
# sudo amazon-linux-extras install docker -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker

sudo usermod -a -G docker ec2-user

# Pull the Docker image from GitHub Container Registry (or Docker Hub)
git clone https://github.com/gmarseglia/SDCC-Server.git

# Build the Docker image
cd SDCC-Server
sudo docker build -t sdcc-server .

# Run the Docker container
sudo docker run -d -p 55555:55555 -p 55556:55556 --name sdcc-server sdcc-server:latest

