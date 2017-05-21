# Prepare VM

This step take about 5 mins.

Create a VM with **Ubuntu 16.04 LTS**.
GCP Machine type: *n1-standard-1* (1 vCPU, 3.75 GB memory) is fast enough.
Note that smaller machine types take very long time to build things,
Debian Jessie and Ubuntu 14.04 LTS didn't go smooth when testing DeepDive.

Install some basic tools:

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
    pkill -u `whoami` # this will log you out. Re-login again to have docker group settings enabled.
    docker run hello-world # make sure you can run docker
    
# Build and test DeepDive Docker

This step takes about 15m.

    git clone https://github.com/HazyResearch/deepdive.git # take about 3m
    cd deepdive
    git submodule update --init
    time ./DockerBuild/build-in-container # need jq, take about 5m
    time ./DockerBuild/test-in-container-postgres # take about 6m

# Build DeepDive on local VM

    make depends # help you install required build tools
    make install # target: ~/local

