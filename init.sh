#!/bin/bash
#master机器ip
MasterIP="192.168.2.11"
#slave机器ip
SlaveIp="192.168.2.13"

#主从同步账号密码
MASTER_USER="root"
MASTER_PASSWORD="root"

#master机mysql登录账号密码
Muser="root"
Mpass="root"

#slave机mysql登录账号密码
Suser="root"
Spass="root"

#slave机ssh的登录账号密码
SSHuser="root"
SSHpass=" "
cp slave/.slave.sh slave/slave.sh

export MYSQL_PWD=${Mpass}

function Master(){
   function mstscSSH(){
	echo -e "create ssh key ...\033[32m done \033[0m"
        #echo -e "\033[43;35m 开始配置双机交互，请按回车后输入slave机登录密码 \033[0m"
	yum  install sshpass > /dev/null 2>&1
	sshpass -p '`SSHpass`' ssh-copy-id -f  ${SSHuser}@${SlaveIp} >/dev/null  
    }

   function cleanData(){
	docker-compose -f master/master-mysql-5.7.yaml down 
	docker rm -f mysql > /dev/null 2>&1
	#rm -rf master/data
    }

function start(){
	docker-compose -f master/master-mysql-5.7.yaml up -d
	sleep 10
	docker cp master/master.sh mysql:/master.sh 
	echo -e ""
	docker exec -i mysql /bin/bash -c "cd / | chmod +x master.sh | ./master.sh" > binlog.txt
}

mstscSSH
cleanData 
start

logfile=$(awk 'END{print $1}' binlog.txt)
sed -i "1i\MasterIP=\"${MasterIP=}\"\n HOSTNAME=\"127.0.0.1\"\n USERNAME=\"${Muser}\"\n PASSWORD=\"${Muser}\" \n DBNAME=\"testdb\"\n MASTER_LOG_FILE=\"${logfile}\"" slave/slave.sh
echo $logfile

echo -e "master ...\033[32m done \033[0m"

}


#SLAVE
function Slave(){
    function Ssync(){
	echo "------2------------"
	rsync -Lrza ./ --exclude example/data ${SSHuser}@${SlaveIp}:`pwd`
	ssh ${SSHuser}@${SlaveIp} "chmod -R +x "`pwd`"/slave/"
	ssh ${SSHuser}@${SlaveIp} "docker-compose -f  "`pwd`"/slave/slave-mysql-5.7.yaml down"
	ssh ${SSHuser}@${SlaveIp} "docker rm -f mysql" >/dev/null 2>&1 
	ssh ${SSHuser}@${SlaveIp} "rm -rf  "`pwd`"/slave/data"
	ssh ${SSHuser}@${SlaveIp} "docker-compose -f  "`pwd`"/slave/slave-mysql-5.7.yaml up -d"
	ssh ${SSHuser}@${SlaveIp} "docker cp "`pwd`"/slave/slave.sh mysql:/slave.sh"
	sleep 10
  	ssh ${SSHuser}@${SlaveIp} "sh "`pwd`"/slave/set-slave.sh"
}
echo "开始同步配置"
Ssync
}
 

 
function main(){
    Master
    Slave
}
main
