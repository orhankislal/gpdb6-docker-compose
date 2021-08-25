#! /bin/bash
GPDB_VERSION=$1

# Install GPDB
cd /gpdb${GPDB_VERSION}-src
make install

# Source GPDB and install pygresql
source /usr/local/gpdb${GPDB_VERSION}/greenplum_path.sh
pip install pygresql

# Start sshd server
/usr/sbin/sshd
