# Dockerfile for DeepDive developers
FROM hazyresearch/deepdive-build
MAINTAINER kongvc@gmail.com

ARG USER=user
ENV USER=$USER

USER root
RUN apt-get update \
 && apt-get install -y python3-pip python-virtualenv python3-virtualenv apt-transport-https \
 && curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - \
 && add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/debian \
     $(lsb_release -cs) \
     stable" \
 && apt-get update \
 && apt-get install -y docker-ce \
        vim \
 && usermod -a -G docker $USER \
 && apt-get clean && rm -rf /var/lib/apt/lists/*
    
# Update source code from GitHub then run make.
# Run make test later when you want to.
USER $USER
RUN git checkout master && git pull origin master \ 
 && make depends install \
 && echo 'export PATH="~/local/bin:$PATH"' >> ~/.bashrc
 
# Install Jupyter Python Notebook into virtual env
# Let pip3 install six before simplegeneric before jupyter.
SHELL ["/bin/bash", "-c"]
RUN virtualenv -p python3 env \
 && source env/bin/activate \
 && pip3 install --upgrade pip \
 && pip3 install six simplegeneric jupyter
