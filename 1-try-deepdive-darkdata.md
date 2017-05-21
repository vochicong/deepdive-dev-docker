# Prepare VM

This step take about 5 mins.

Create a VM with **Ubuntu 16.04 LTS**.
GCP Machine type: *n1-standard-1* (1 vCPU, 3.75 GB memory) is fast enough.
Note that smaller machine types take very long time to build things,
Debian Jessie and Ubuntu 14.04 LTS didn't go smooth when testing DeepDive.

Install some basic tools:

    sudo apt-get install --yes software-properties-common apt-transport-https nodejs npm git jq

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

## Build

    time ./DockerBuild/build-in-container # need jq, take about 5m

## Test

    time ./DockerBuild/test-in-container-postgres # take about 6m

# Build DeepDive on local VM

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
