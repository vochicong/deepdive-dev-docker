# Dockerfile for DeepDive developers
FROM hazyresearch/deepdive-build
MAINTAINER kongvc@gmail.com

ARG USER=user
ENV USER=$USER

USER root
RUN apt-get update \
 && apt-get install -y python-pip python-virtualenv apt-transport-https \
 && curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - \
 && add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/debian \
     $(lsb_release -cs) \
     stable" \
 && apt-get update \
 && apt-get install -y docker-ce \
 && usermod -a -G docker $USER \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
    
# Update source code from GitHub then run make.
USER $USER
RUN git checkout master && git pull origin master \ 
 && make depends install test \
 && echo 'export PATH="~/local/bin:$PATH"' >> ~/.bashrc
 
# Install Jupyter Python Notebook into virtual env
SHELL ["/bin/bash", "-c"]
RUN virtualenv env \
 && source env/bin/activate \
 && pip install --upgrade pip \
 && pip install jupyter
