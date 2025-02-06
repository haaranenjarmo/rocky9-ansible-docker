FROM rockylinux:9-minimal
LABEL maintainer="Jarmo Haaranen"
LABEL description="Ansible Core on Rocky Linux 9"
LABEL version="1.0.4"

# Upgrade and install packages
RUN microdnf -y upgrade \
     && microdnf -y install \
     curl \
     dnf-plugins-core \
     ca-certificates \
     python3.12 \
     python3.12-pip \
     sudo \
     && microdnf clean all

# Upgrade pip
RUN python3.12 -m pip install --upgrade pip

# Create ansible user
RUN groupadd -g 1001 ansible \
    && useradd -u 1001 -g ansible -m -s /bin/bash -d /home/ansible ansible \
    && echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible


# Switch user context to ansible
USER ansible

ENV PATH="/home/ansible/.local/bin:${PATH}"

# Copy both requirements.txt and collections.yml in one step
COPY requirements.txt collections.yml /home/ansible/

# Install Python packages, ansible collections and remove tmp files
RUN pip install -r /home/ansible/requirements.txt \
  && ansible-galaxy collection install -r /home/ansible/collections.yml

WORKDIR /home/ansible
