# Prepare workspace VM

For a workspace, create a VM with **Debian Jessie**, with more than 4 GB of memory an **100GB** of disk.
Note that 
- low spec machine types take very long time to build things. 
- a default GCP 10GB disk will get full during DeepDive build or docker pull, so don't select it.

Install and make sure that you can run docker properly.

    docker run hello-world # make sure you can run docker
    
# Quick Start for DeepDive users

    git clone --depth 1 https://github.com/HazyResearch/deepdive.git
    cd deepdive/sandbox
    docker-compose pull

Edit `deepdive/sandbox/docker-compose.yml`
to expose port `8000`. Start the dockers by

    docker-compose up --no-build 

When the dockers running, you can 
access `DeepDive` Jupyter notebooks at `http://localhost:8888`,
and `Mindbender` at `http://localhost:8000`.

Note that the host machine (your Mac or VM) don't have enough memory
`deepdive corenlp start` will freeze or crash later.

# DeepDive development using Docker, for developers

[Dockerfile](Dockerfile) and [docker-compose.yml](docker-compose.yml) 
with all steps below executed are attached.

To start a docker container that will work as our development environment

    docker run --name deepdive-devenv -it --privileged -v /var/run/docker.sock:/var/run/docker.sock hazyresearch/deepdive-build bash

After stopping the docker, you can start it again by:

    docker start -i deepdive-devenv
    
Inside the host docker, update source code from GitHub then run make.

    cd /deepdive && git checkout master && git pull origin master \
    && time make depends test install \
    && echo 'export PATH="~/local/bin:$PATH"' >> ~/.bashrc && . ~/.bashrc
    
Install Jupyter Python Notebook via pip

    sudo apt-get install -y python-pip python-virtualenv
    virtualenv env
    source env/bin/activate
    pip install --upgrade pip
    pip install jupyter
    jupyter notebook

# DeepDive build and testing using Docker (as done in TravisCI)

## Build

    sudo apt-get install -y jq software-properties-common nodejs npm 
    time make build--in-container # need jq, take about 5m

## Test

    time make test--in-container # take about 6m

## Inspect

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

    sudo apt-get install --yes software-properties-common nodejs npm git jq

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

## To checkout DeepDive source

    git clone https://github.com/HazyResearch/deepdive.git
    cd deepdive
    git submodule update --init

## Docker installation for Debian

    sudo apt-get update
    sudo apt-get install -y apt-transport-https
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/debian \
        $(lsb_release -cs) \
        stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce
    sudo usermod -a -G docker `whoami`   
    pkill -u `whoami` # this will log you out. Re-login again to have docker group settings enabled.
    
## Some Docker commands

    docker system prune -af # Remove all unused docker data
    docker system df # Show docker disk usage
    docker ps -a # Show all containers
    
