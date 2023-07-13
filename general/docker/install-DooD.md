Install DooD (Docker outside of Docker)

The machine you are running these scripts on must already have docker installed.
It wil perform the following actions.

1. Build a local Docker Image named customjenkins (using Dockerfile). The plugin git will be install. The packer and docker compose will also be installed on the container.
2. It will look for a docker volume named 'jenkins_home' (for data persistence).
3. Create a container using the customjenkins Image and use the volume created in step 2.

The jenkins container will be available for view using the http://localhost:8079