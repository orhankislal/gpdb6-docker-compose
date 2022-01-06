#! /bin/bash
set -x

source /gpdb-scripts/cleanup.sh

# Run gpinitsystem as gpadmin user
su - gpadmin -c "

   # Run gpinitsystem
   cd /gpdb-scripts
   source /usr/local/gpdb5/greenplum_path.sh
   gpinitsystem -a -c configs/clusterConfigFile-GP5 -p configs/clusterConfigPostgresAddonsFile -h configs/hostfile
   echo '/data/sbdir' | gpinitstandby -a -s cdw -P 5001

   psql postgres -f /gpdb-scripts/drop_hdfs.sql
"

su - gpadmin -c "
   # Compile gpupgrade
   rm -rf ~/.gpupgrade ; gpupgrade kill-services ; pkill gpupgrade
   cd /gpupgrade
   make && make install

   ssh sdw1 'mkdir -p ~/go/bin' ; scp ~/go/bin/gpupgrade sdw1:~/go/bin
   ssh sdw2 'mkdir -p ~/go/bin' ; scp ~/go/bin/gpupgrade sdw2:~/go/bin

   psql postgres -c 'create table test1 as select 1.2 as i'
   # gpupgrade initialize --source-gphome /usr/local/gpdb5 --target-gphome /usr/local/gpdb6 --source-master-port 5000 --disk-free-ratio 0 -a --skip-version-check --mode link --pg-upgrade-jobs 2
"
