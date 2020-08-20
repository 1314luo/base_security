#!/bin/bash
export ANSIBLE_LOG_PATH=/var/log/kolla/mariadb/mariadb_recovery.log

recovery(){

   ansible -i /etc/ansible/hosts control -m shell  -a "docker stop mariadb"

   sleep 5

   echo "`date "+%Y-%m-%d %H:%M:%S"` Mariadb recovery " >> /var/log/kolla/mariadb/mariadb_recovery_info.log

   kolla-ansible -i /etc/ansible/hosts mariadb_recovery

}

ansible -i /etc/ansible/hosts control -m shell  -a "docker ps|grep mariadb"
mariadb_container_status=$?

echo "`date "+%Y-%m-%d %H:%M:%S"` Mariadb Check. " >> /var/log/kolla/mariadb/mariadb_recovery_info.log

while [ $mariadb_container_status != 0 ]
do
   sleep 5
   ansible -i /etc/ansible/hosts control -m shell  -a "docker ps|grep mariadb"
   mariadb_container_status=$?
   echo "`date "+%Y-%m-%d %H:%M:%S"` sleep 5" >> /var/log/kolla/mariadb/mariadb_recovery_info.log
done

netstat -anp|grep ":3306"|grep ESTABLISHED
mariadb_status=$?
if [ $mariadb_status == 0 ] && [ $mariadb_container_status == 0 ]
then
  sleep 5
  netstat -anp|grep ":3306"|grep ESTABLISHED
  mariadb_status2=$?
  if [ $mariadb_status2 == 0 ]
  then
     echo "`date "+%Y-%m-%d %H:%M:%S"` Mariadb startup completed." >> /var/log/kolla/mariadb/mariadb_recovery_info.log
  else
     recovery
  fi
else
  recovery
fi
