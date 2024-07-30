#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGDB_HOST=mongodb.devops76s.online

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

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

dnf module disable nodejs -y

VALIDATE $? "$R Disabling current nodeJs $N" &>> $LOGFILE

dnf module enable nodejs:18 -y

VALIDATE $? "$Y Enabling nodeJs:18 $N" &>> $LOGFILE

dnf install nodejs -y

VALIDATE $? "$G Installing nodeJs:18 $N" &>> $LOGFILE

id roboshop # if roboshop user doesnot exits, then it is a failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation" &>> $LOGFILE
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi        

mkdir -p /app

VALIDATE $? "Creating Directory" &>> $LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "Downloading Catalogue application" &>> $LOGFILE

cd /app 

unzip -o /tmp/catalogue.zip

VALIDATE $? "$R Unzipping Catalogue $N" &>> $LOGFILE

npm install 

VALIDATE $? "$G Installing Dependencies $N" &>> $LOGFILE

#use absoulte path, because catalogue.service exists there
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service

VALIDATE $? "$Y Coping catalogue service file $N" &>> $LOGFILE

systemctl daemon-reload

VALIDATE $? "$G Catalogue Demon reload $N" &>> $LOGFILE

systemctl enable catalogue

VALIDATE $? "Enable catalogue" &>> $LOGFILE

systemctl start catalogue

VALIDATE $? "Starting catalogue" &>> $LOGFILE

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copied MongoDB Repo" 

dnf install mongodb-org-shell -y

VALIDATE $? "$G Installing MongoDB client $N" &>> $LOGFILE

mongo --host $MONGDB_HOST </app/schema/catalogue.js

VALIDATE $? "Loding catalogue data into MongoDB client" &>> $LOGFILE







