echo ">>>>>> Create Catalouge Service <<<<<<"
cp catalogue.service /etc/systemd/system/catalogue.service

echo ">>>>>> Create MongoDB Repo <<<<<<"
cp mongo.repo /etc/yum.repos.d/mongo.repo

echo ">>>>>> Install NodeJS Repos <<<<<<"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash

echo ">>>>>> Install NodeJS <<<<<<"
yum install nodejs -y

echo ">>>>>> Create Application User <<<<<<"
useradd roboshop

echo ">>>>>> Create Application Directory <<<<<<"
mkdir /app

echo ">>>>>> Download Application Content <<<<<<"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip

echo ">>>>>> Extract Application Content <<<<<<"
cd /app
unzip /tmp/catalogue.zip
cd /app

echo ">>>>>> Download NodeJS Dependencies <<<<<<"
npm install

echo ">>>>>> Install MongoDB Client <<<<<<"
yum install mongodb-org-shell -y

echo ">>>>>> Load Catalouge Schema <<<<<<"
mongo --host mongodb.kdevops72.online </app/schema/catalogue.js

echo ">>>>>> Start Catalouge Service <<<<<<"
systemctl daemon-reload
systemctl enable catalogue
systemctl restart catalogue
