# To connect Cloud9 to GCP VM
sudo apt-get install --yes nodejs git

# Build and test DeepDive Docker on Ubuntu 16.04 LTS
git clone https://github.com/HazyResearch/deepdive.git
cd deepdive
git submodule update --init

make depends

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install --yes docker-ce
sudo usermod -a -G docker `whoami`   
logout

# re login
docker run hello-world
cd deepdive
sudo apt-get install jq --yes
make checkstyle
export DOCKER_IMAGE=hazyresearch/deepdive-build
export POSTGRES_DOCKER_IMAGE=hazyresearch/postgres
docker pull $DOCKER_IMAGE
docker pull $POSTGRES_DOCKER_IMAGE
time ./DockerBuild/build-in-container # need jq
time ./DockerBuild/test-in-container-postgres
