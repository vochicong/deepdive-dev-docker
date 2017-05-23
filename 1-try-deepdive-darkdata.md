# Quick Start using DeepDive Notebooks Docker

    git clone --depth 1 https://github.com/HazyResearch/deepdive.git
    cd deepdive/sandbox
    docker-compose pull

Note that the host machine (your Mac or VM) must have **more than 4GB of memory**,
o.w. `deepdive corenlp start` will freeze or crash later.

Edit `deepdive/sandbox/docker-compose.yml`
to expose port `8000`. Start the dockers by

    docker-compose up --no-build 

When the dockers running, you can access `DeepDive` Jupyter notebooks at `http://localhost:8888`,
and `Mindbender` at `http://localhost:8000`.

# Build and test DeepDive using Docker

## Prepare host docker

This step take about 5 mins.

Create a VM with **Ubuntu 16.04 LTS**.
GCP Machine type: *n1-standard-2* (1 vCPU, > 4 GB memory, **40GB** of disk) is good enough.
Note that 
- smaller machine types take very long time to build things. 
- a default GCP 10GB disk will get full during DeepDive build or docker pull, so don't select it.
- Debian Jessie and Ubuntu 14.04 LTS don't go smooth when testing DeepDive.

The steps takes about 15m.

Ref: [deepdive/.travis.yml](https://github.com/HazyResearch/deepdive/blob/master/.travis.yml)

To start a docker container that will work as our development environment

    git clone --depth 1 https://github.com/HazyResearch/deepdive.git
    docker run -it -v `pwd`/deepdive:/deepdive debian bash

Inside the host docker, install basic tools and dependencies.

    apt-get update
    apt-get install -y curl sudo cmake
    cd /deepdive
    time util/install.sh _deepdive_build_deps _deepdive_runtime_deps
    make depends
    

## Install Docker into the host Docker

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
    
## Checkout source

    git clone https://github.com/HazyResearch/deepdive.git # take about 3m
    cd deepdive
    git submodule update --init

## Build

    time ./DockerBuild/build-in-container # need jq, take about 5m

## Test

    time ./DockerBuild/test-in-container-postgres # take about 6m

## Play

To run interactive commands on the sample and test results, start the container:

    ./DockerBuild/inspect-container-psql

Inside the container:

    export PATH=/deepdive/dist/stage/bin:$PATH
    which deepdive # verify /deepdive/dist/stage/bin/deepdive
    cd /deepdive
    make test
    cd /deepdive/examples/spouse
    deepdive do articles
    deepdive query '?- articles("5beb863f-26b1-4c2f-ba64-0c3e93e72162", content).' format=csv | grep -v '^$' | tail -n +16 | head

# Build DeepDive on local VM

The steps may take an hour.

Ref: [Building and Testing DeepDive](http://deepdive.stanford.edu/developer)

Install some basic tools:

    sudo apt-get install --yes software-properties-common apt-transport-https nodejs npm git jq

## Build

To install DeepDive into `~/local/bin`

    make depends # help you install required build tools
    make install 
    
It will fail the 1st time, saying `bower` not found.

    cd util/mindbender/gui/frontend && npm install bower
    make install # now try it again
    ls ~/local/bin 
    > ddlog  deepdive  mindbender
    export PATH=~/local/bin:$PATH # ~/local/bin/deepdive

## Test

Testing requires PostgreSQL, ts, pbzip2 and Pyhocon, psycopg2 and ujson.

    sudo apt-get install postgresql moreutils python-pip python-virtualenv pbzip2 --yes
    sudo pip install --upgrade pip
    sudo chown -R `whoami` ~/.cache
    virtualenv env
    source env/bin/activate
    pip install psycopg2 pyhocon ujson

Create a PostgreSQL dbuser with SUPERUSER permissions.

    sudo -s -u postgres
    psql
    ALTER ROLE dbuser WITH SUPERUSER;
    
then run tests:

    export PATH=~/.local/bin:$PATH # ~/.local/bin/pyhocon
    export TEST_DBHOST=dbuser:dbpassword@localhost
    make test # 164 tests, 0 failures, 7 skipped, takes about 3min 
    make test ONLY=test/postgresql/spouse_example.bats # 10 tests, 0 failures, 2 skipped

If errors happen (see 2-test-spouse-example.log), 
you may need to install some software dependencies.

# Misc.

## Docker cleanup

    docker system prune -a
    docker ps -a
    docker system df
    
