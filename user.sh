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

VALIDATE $? "Disabling current nodeJs" &>> $LOGFILE

dnf module enable nodejs:18 -y

VALIDATE $? "Enabling nodeJs:18" &>> $LOGFILE

dnf install nodejs -y

VALIDATE $? "Installing nodeJs:18" &>> $LOGFILE

id roboshop # if roboshop user doesnot exits, then it is a failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation" &>> $LOGFILE
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi        

VALIDATE $? "Creating Roboshop user" &>> $LOGFILE

mkdir -p /app

VALIDATE $? "Creating Directory" &>> $LOGFILE

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip

VALIDATE $? "Downloading user application" &>> $LOGFILE

cd /app 

unzip -o /tmp/user.zip

VALIDATE $? "Unzipping user" &>> $LOGFILE

npm install 

VALIDATE $? "Installing Dependencies" &>> $LOGFILE


#use absoulte path, because catalogue.service exists there
cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service

VALIDATE $? "Coping user service file" &>> $LOGFILE

systemctl daemon-reload

VALIDATE $? "User Demon reload" &>> $LOGFILE

systemctl enable user

VALIDATE $? "Enable user" &>> $LOGFILE

systemctl start user

VALIDATE $? "Starting user" &>> $LOGFILE

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copied MongoDB Repo" 

dnf install mongodb-org-shell -y

VALIDATE $? "Installing MongoDB client" &>> $LOGFILE

mongo --host $MONGDB_HOST </app/schema/user.js

VALIDATE $? "Loding user data into MongoDB " &>> $LOGFILE



