#! /bin/bash
set -x

pkill postgres ; rm -rf /tmp/.s.PG* ; rm -rf ~/gpAdminLogs /data/qddir /data/sbdir /tmp/ts1/*
mkdir -p /data/qddir /tmp/ts1 ; chown -R gpadmin:gpadmin /data/qddir /data /tmp/ts1

for host in sdw1 sdw2; do
   ssh ${host} 'pkill postgres ; rm -rf /tmp/.s.PG* /tmp/ts1/* ; rm -rf /data/primary /data/mirror ~/gpAdminLogs'
   ssh ${host} 'mkdir -p /data/primary /data/mirror /tmp/ts1/seg1/ /tmp/ts1/mir1/; chown -R gpadmin:gpadmin /data/primary /data/mirror'
done

# Create environment file
rm -rf ~gpadmin/env.sh
cat > ~gpadmin/env.sh <<EOF
#! /bin/bash

source /usr/local/gpdb5/greenplum_path.sh
export MASTER_DATA_DIRECTORY=/data/qddir/gpseg-1
export PGPORT=5000

EOF

rm -rf  ~gpadmin/gosetup.sh
cat > ~gpadmin/gosetup.sh <<EOF
#! /bin/bash
export GOBIN=/home/gpadmin/go/bin
export PATH=/home/gpadmin/go/bin:~/workspace/go/bin:~/workspace/protoc/bin:\$PATH
export GOMODCACHE=/home/gpadmin/go/pkg/mod

EOF

grep -qxF 'source ~gpadmin/env.sh"' ~gpadmin/.bash_profile || echo 'source ~gpadmin/env.sh' >> ~gpadmin/.bash_profile
grep -qxF 'source ~gpadmin/gosetup.sh"' ~gpadmin/.bash_profile || echo 'source ~gpadmin/gosetup.sh' >> ~gpadmin/.bash_profile
