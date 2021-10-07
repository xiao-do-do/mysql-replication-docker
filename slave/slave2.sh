#!/bin/bash

HOSTNAME="127.0.0.1"
PORT="3306"
USERNAME="root"
PASSWORD="root"
DBNAME="testdb"
TABLENAME="test_table_test"
MASTER_LOG_FILE=""

export MYSQL_PWD=${PASSWORD}

mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME}   -e  "stop slave;"
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME}   -e  "reset slave;"
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME}   -e "DROP DATABASE IF EXISTS ${DBNAME};" 
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME}   -e "CREATE DATABASE  ${DBNAME} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;" 

mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME}   -e  "CHANGE MASTER TO MASTER_HOST='192.168.2.11',MASTER_USER='root',MASTER_PASSWORD='root',MASTER_LOG_FILE='mysql-bin.000001',MASTER_LOG_POS=154;"
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME}   -e  "start slave";

IO=$(mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME}   -e "show slave status \G;" | grep Slave_IO_Running | awk '{print $2}')
SQL=$(mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME}   -e "show slave status\G;" | grep Slave_SQL_Running | awk '{print $2}')

#
if [[ $IO == "Yes" && $SQL =~ "Yes" ]];then
	 echo -e "\e[32mreplication done \e[0m"
else
	echo -e "\e[31mreplication fail\e[0m"
fi


