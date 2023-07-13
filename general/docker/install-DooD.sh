#!/bin/bash

if [[ $(lsb_release -rs) == "20.04" && $(lsb_release -is) == "Ubuntu" ]]; then
    echo "This machine is running Ubuntu 20.04"
else
    echo "This machine is not running Ubuntu 20.04, you have issues with docker build."
    exit 1
fi

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