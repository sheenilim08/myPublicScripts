Install DooD (Docker outside of Docker)

It wil perform the following actions.

1. Install Docker on Host.
2. Build a local Docker Image named customjenkins (using Dockerfile). The plugin git will be install. The packer and docker compose will also be installed on the container.
3. It will look for a docker volume named 'jenkins_home' (for data persistence).
4. Create a container using the customjenkins Image and use the volume created in step 2.

The jenkins container will be available for view using the http://localhost:8079

Credits: This script is based on the technical documentation of Adrian Mouat
https://blog.container-solutions.com/running-docker-in-jenkins-in-docker