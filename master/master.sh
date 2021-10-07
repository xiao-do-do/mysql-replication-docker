#!/bin/bash
if [ ! -f /.dockerenv ]; then 
	echo "主从同步脚本，复制到docker里运行"
	exit
fi
HOSTNAME="127.0.0.1"  
PORT="3306"
USERNAME="root"
PASSWORD="root"
DBNAME="testdb" 
TABLENAME="test_table_test" 
export MYSQL_PWD=${PASSWORD}


mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME}  -e "grant replication slave on *.* to 'root'@'%' identified by 'root'" 

if [ $? -eq 0 ];then
	echo -e "账户 "${USERNAME}"，同步授权成功\n"
else
	echo -e "账户  "${USERNAME}"，同步授权失败\n"
fi

mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME}   -e "flush privileges;" 
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME}   -e "reset master;" 
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME}   -e "show master status;"
