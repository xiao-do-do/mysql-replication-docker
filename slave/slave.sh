MasterIP="192.168.2.11"
 HOSTNAME="127.0.0.1"
 USERNAME="root"
 PASSWORD="root" 
 DBNAME="testdb"
 MASTER_LOG_FILE="mysql-bin.000001"
#!/bin/bash


export MYSQL_PWD=${PASSWORD}

mysql   -u${USERNAME}   -e  "stop slave;"
mysql   -u${USERNAME}   -e  "reset slave;"
mysql  -u${USERNAME}   -e "DROP DATABASE IF EXISTS ${DBNAME};" 
mysql   -u${USERNAME}   -e "CREATE DATABASE  ${DBNAME} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;" 

mysql   -u${USERNAME}   -e  "CHANGE MASTER TO MASTER_HOST='${MasterIP}',MASTER_USER='${USERNAME}',MASTER_PASSWORD='${PASSWORD}',MASTER_LOG_FILE='${MASTER_LOG_FILE}',MASTER_LOG_POS=154;"
mysql   -u${USERNAME}   -e  "start slave";

IO=$(mysql  -u${USERNAME}   -e "show slave status \G;" | grep Slave_IO_Running | awk '{print $2}')
SQL=$(mysql  -u${USERNAME}   -e "show slave status\G;" | grep Slave_SQL_Running | awk '{print $2}')

#
if [[ $IO == "Yes" && $SQL =~ "Yes" ]];then
	 echo -e "\e[32mreplication done \e[0m"
else
	echo -e "\e[31mreplication fail\e[0m"
fi


