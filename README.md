# Rocky Linux 9 Ansible Docker Image

This repository contains Dockerfile to build
Rocky Linux 9 Ansible Docker image.

I'm using this image for only testing purposes.
Do not build production image using this repo.

## Configurations

All installed python packages are listed in ***requirements.txt*** file
Installed ansible collections are listed in ***collections.yml*** file

Workdir is ***/app*** directory

## Container user

Container user name is ***ansible*** and it's home directory is
in ***/home/ansible***.

Ansible user id is ***1001*** and ansible group id is ***1001***

User has been added to sudoers group.
