#! /usr/bin/env bash
set -e

ES_VERSION='2.4.2'
DEB='elasticsearch-'"$ES_VERSION"'.deb'
URL="https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/$ES_VERSION/$DEB"

if ! [ -e $SEMAPHORE_CACHE_DIR/$DEB ]; then (cd $SEMAPHORE_CACHE_DIR; wget $URL); fi

sudo service elasticsearch stop
sudo dpkg -r elasticsearch

echo ">> Installing ElasticSearch $ES_VERSION"
echo Y | sudo dpkg -i $SEMAPHORE_CACHE_DIR/$DEB

sudo sh -c "echo 'script.engine.groovy.inline.search: on' >> /etc/elasticsearch/elasticsearch.yml"
sudo sh -c "echo 'script.inline: on' >> /etc/elasticsearch/elasticsearch.yml"
sudo sh -c "echo 'script.indexed: on' >> /etc/elasticsearch/elasticsearch.yml"
sudo service elasticsearch start

GIT_VERSION=${1:-'2.8.1-1'}

TAR="git-$GIT_VERSION-min-openssl.tar.gz"
URL="https://s3-us-west-2.amazonaws.com/container-libraries/packages/$TAR"

echo "---------------------------------------"
echo "Installing git $GIT_VERSION"
echo "---------------------------------------"

if ! [ -e $SEMAPHORE_CACHE_DIR/$TAR ]; then (cd $SEMAPHORE_CACHE_DIR; wget $URL); fi
sudo tar xf $SEMAPHORE_CACHE_DIR/$TAR -C /tmp
sudo dpkg -i /tmp/*.deb

git config --global url."https://".insteadOf git://
git config --global --add http.sslVersion tlsv1.1

# print post-installation info
echo "---------------------------------------"
printf "\nInstallation complete.\n\nDetails:\n $(git --version)\n"
