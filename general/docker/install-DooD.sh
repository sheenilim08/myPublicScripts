#!/bin/bash

if ! docker build -t customjenkins .; then
    echo "An error occurred while building the Docker image"
    exit 1
fi

if [ "$(docker volume ls | grep jenkins_home)" ]; then
    echo "Volume jenkins_home already exists"
else
    docker volume create jenkins_home
    echo "Volume jenkins_home created"
fi

docker run -p 8079:8080 -d --name jenkins -p 50000:50000 -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -v $(which docker):/usr/bin/docker customjenkins