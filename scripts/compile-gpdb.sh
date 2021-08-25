#! /bin/bash

cd /gpdb5-src
git submodule update --init --recursive
./configure --disable-orca --disable-gpcloud --with-libxml --with-python --with-perl --enable-mapreduce --enable-debug --prefix=/usr/local/gpdb5
make -j8
cd ../gpdb6-src
git submodule update --init --recursive
./configure --disable-orca --disable-gpcloud --with-libxml --with-python --with-perl --enable-mapreduce --enable-debug --prefix=/usr/local/gpdb6
make -j8

cd /tmp
rm -rf bats-core
git clone https://github.com/bats-core/bats-core.git
cd bats-core/
./install.sh /usr/local
yum install -y sudo
yum install -y automake
yum install -y ag

chown -R gpadmin:gpadmin /gpupgrade
su - gpadmin -c "

   PB_REL="https://github.com/protocolbuffers/protobuf/releases"
   curl -LO $PB_REL/download/v3.15.8/protoc-3.15.8-linux-x86_64.zip
   mkdir -p ~/workspace/protoc/
   unzip protoc-3.15.8-linux-x86_64.zip -d ~/workspace/protoc/

   wget https://golang.org/dl/go1.16.9.linux-amd64.tar.gz
   tar -zxvf go1.16.9.linux-amd64.tar.gz -C ~/workspace/
"
