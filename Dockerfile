FROM  rockylinux:9
LABEL maintainer="Jarmo Haaranen"
LABEL description="Ansible Core on Rocky Linux 9"
LABEL orginal="https://github.com/geerlingguy/docker-rockylinux9-ansible/tree/master"
LABEL version="1.0.5"

RUN yum -y install rpm dnf-plugins-core \
    && yum -y update && yum -y upgrade \
    && yum -y install \
      epel-release \
      initscripts \
      sudo \
      which \
      hostname \
      libyaml \
      ca-certificates \
      python3.12 \
      python3.12-pip \
      python3.12-pyyaml \
      iproute \
      podman \
    && yum clean all

RUN dnf update -y \
    && dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

RUN dnf install -y docker-ce docker-ce-cli containerd.io \
    && systemctl enable docker

# Upgrade pip
RUN python3.12 -m pip install --upgrade pip

# Disable requiretty.
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible 
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

RUN mkdir -p /usr/local/lib/python3.12/site-packages/ansible_collections \
    && chmod 755 /usr/local/lib/python3.12/site-packages/ansible_collections

# Create ansible user
RUN groupadd -g 1001 ansible \
    && useradd -u 1001 -g ansible -m -s /bin/bash -d /home/ansible ansible \
    && echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible \
    && usermod -aG docker ansible

# Switch user context to ansible
USER ansible

ENV PATH="/home/ansible/.local/bin:${PATH}"

# Copy both requirements.txt and collections.yml in one step
COPY requirements.txt collections.yml /home/ansible/

# Install Python packages, ansible collections and remove tmp files
RUN pip install -r /home/ansible/requirements.txt \
  && ansible-galaxy collection install -r /home/ansible/collections.yml

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]
