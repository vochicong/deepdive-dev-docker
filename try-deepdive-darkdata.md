# Prepare GCP VM

Create a GCP VM, type: n1-standad-1, OS: Ubuntu 16.04 LTS, SSD: 10GB.
Install some basic softwares:

    sudo apt-get install --yes software-properties-common apt-transport-https nodejs git jq

Install Docker

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"
    sudo apt-get update
    sudo apt-get install --yes docker-ce
    sudo usermod -a -G docker `whoami`   
    logout # relogin
    docker run hello-world # make sure you can run docker
    
# Build and test DeepDive Docker on Ubuntu 16.04 LTS

    git clone https://github.com/HazyResearch/deepdive.git
    cd deepdive
    git submodule update --init
    time ./DockerBuild/build-in-container # need jq, take about 5m
    time ./DockerBuild/test-in-container-postgres
    # make depends # may help you install required build tools
