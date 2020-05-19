# Pull the base terraform execution environment image from docker hub
FROM cejkyle/terraform-exec-env AS terraformexecvenv
# These are the private and public ssh key variables passed in from the command line
# The public key has already been added to github

ARG ssh_prv_key
ARG ssh_pub_key
ARG project_folder

RUN apk --update add openssh-client 

# Authorize SSH Host
RUN mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh && \
    ssh-keyscan github.com > /root/.ssh/known_hosts

RUN  echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config

# Add the keys and set specific permissions needed by ssh-keyscan
RUN echo "$ssh_prv_key" > /root/.ssh/id_rsa && \
    echo "$ssh_pub_key" > /root/.ssh/id_rsa.pub && \
    chmod 600 /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa.pub

# Clone the conf files into the docker container

# Create a repo folder
RUN mkdir -p /root/repo/

# Change to this folder
WORKDIR "/root/repo/$project_folder"

# Clone via SSH 
RUN git clone git@github.com:cejkyle/101-key-vault-create.git
RUN /go/terraform-bundle/terraform init && \
    /go/terraform-bundle/terraform validate
