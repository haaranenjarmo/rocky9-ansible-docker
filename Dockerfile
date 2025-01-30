FROM rockylinux:9-minimal
LABEL maintainer="Jarmo Haaranen"
LABEL description="Ansible Core on Rocky Linux 9"
LABEL version="1.0.0"

# Upgrade and install packages
RUN microdnf -y upgrade \
     && microdnf -y install \
     python3.12 \
     python3.12-pip \
     sudo \
     && microdnf clean all

# Upgrade pip
RUN python3.12 -m pip install --upgrade pip

# Create ansible user
RUN groupadd -g 1001 ansible \
    && useradd -u 1001 -g ansible -m -s /bin/bash ansible \
    && echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible

# Switch user context to ansible
USER ansible

ENV PATH="/home/ansible/.local/bin:${PATH}"

# Copy requirements.txt to container
COPY requirements.txt /tmp/requirements.txt

# Copy collections.yml to container
COPY collections.yml /tmp/collections.yml

# Install Python packages and ansible collections
RUN pip install -r /tmp/requirements.txt \
  && ansible-galaxy collection install -r /tmp/collections.yml

CMD ["sleep", "infinity"]