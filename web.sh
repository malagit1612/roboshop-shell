#!/bin/basg

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[30m"
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

dnf install nginx -y

VALIDATE $? "Installing Ngninx"

systemctl enable nginx

VALIDATE $? "Enabling Ngninx"

systemctl start nginx

VALIDATE $? "Starting Ngninx"

rm -rf /usr/share/nginx/html/*

VALIDATE $? "Removing default website"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip

VALIDATE $? "Downloaded web application"

cd /usr/share/nginx/html

VALIDATE $? "Moving nginx html directory"

unzip /tmp/web.zip

VALIDATE $? "Unzipping web"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf 

VALIDATE $? "Copied roboshop reverseproxy config"

systemctl restart nginx 

VALIDATE $? "Restarted nginx"
