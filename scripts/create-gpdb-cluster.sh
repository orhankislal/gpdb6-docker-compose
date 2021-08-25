#! /bin/bash
set -x

# Create data directories
rm -rf ~/.gpupgrade ; gpupgrade kill-services ; pkill gpupgrade

pkill postgres ; rm -rf /tmp/.s.PG* ; rm -rf ~/gpAdminLogs /data/qddir /data/sbdir /tmp/ts1/*
mkdir -p /data/qddir /tmp/ts1 ; chown -R gpadmin:gpadmin /data/qddir

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

echo 'source ~gpadmin/env.sh' >> ~gpadmin/.bash_profile
echo 'source ~gpadmin/gosetup.sh' >> ~gpadmin/.bash_profile

# Run gpinitsystem as gpadmin user
su - gpadmin -c "

   # Run gpinitsystem
   cd /gpdb-scripts
   source /usr/local/gpdb5/greenplum_path.sh
   gpinitsystem -a -c configs/clusterConfigFile -p configs/clusterConfigPostgresAddonsFile -h configs/hostfile
   echo '/data/sbdir' | gpinitstandby -a -s cdw -P 5001

   source ~/env.sh
   source ~/gosetup.sh
   psql postgres -f /gpdb-scripts/drop_hdfs.sql
"

su - gpadmin -c "
   # Run gpinitsystem
   source /usr/local/gpdb5/greenplum_path.sh
   cd /gpupgrade
   make && make install

   ssh sdw1 'mkdir -p ~/go/bin' ; scp ~/go/bin/gpupgrade sdw1:~/go/bin
   ssh sdw2 'mkdir -p ~/go/bin' ; scp ~/go/bin/gpupgrade sdw2:~/go/bin

   rm -rf ~/.gpupgrade ; gpupgrade kill-services ; pkill gpupgrade

   psql postgres -c 'create table test1 as select 1.2 as i'
   # gpupgrade initialize --source-gphome /usr/local/gpdb5 --target-gphome /usr/local/gpdb6 --source-master-port 5000 --disk-free-ratio 0 -a
"
