#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[30m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
exec &>$LOGFILE

echo "script started executing at $TIMESTAMP" 

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2.... $R FAILED $N"
        exit 1
    else
        echo -e "$2.... $G SUCCESS $N"    
    fi    
}

if [ $ID -ne 0 ]
then 
    echo -e "$R ERROR::Please run this script with root access $N"
    exit 1 #you can give other than 0
else 
    echo "you are root user"
fi 


dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y

VALIDATE $? "Install Remi Release" 

dnf module enable redis:remi-6.2 -y

VALIDATE $? "Enabling Redis" 

dnf install redis -y

VALIDATE $? "Installing Redis" 

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf 

VALIDATE $? "Remote access to Redis"

systemctl enable redis 

VALIDATE $? "Enablingarting Redis"

systemctl start redis 

VALIDATE $? "Starting Redis"






