### Version History
Version 1.01
- Now includes terraform
- Fixed the Ubuntu version detection, versions like 20.04.xxx are now allowed on the install-DooD.sh script

Credits: This script is based on the technical documentation of Adrian Mouat
https://blog.container-solutions.com/running-docker-in-jenkins-in-docker

Install DooD (Docker outside of Docker)

It wil perform the following actions.

NOTE: Due to the difference on the kernel used by Host OS (Ubuntu) and Jenkins Image (jenkins/jenkins:lts-jdk11), if you are running version other than Ubuntu 20.04, the script will fail. Otherwise, you will see the error below when performing docker actions in Jenskins.
docker: /lib/x86_64-linux-gnu/libc.so.6: version `GLIBC_2.32' not found (required by docker)
docker: /lib/x86_64-linux-gnu/libc.so.6: version `GLIBC_2.34' not found (required by docker)

1. Install Docker on Host.
2. Build a local Docker Image named customjenkins (using Dockerfile). The plugin git will be install. The packer and docker compose will also be installed on the container.
3. It will look for a docker volume named 'jenkins_home' (for data persistence).
4. Create a container using the customjenkins Image and use the volume created in step 2.

The jenkins container will be available for view using the http://localhost:8079

