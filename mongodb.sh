cp mongo.repo /etc/yum.repos.d/mongo.repo
yum install mongodb-org -y
#update listen address 127.0.0.1 to 0.0.0.0
systemctl daemon-reload
systemctl enable mongod
systemctl restart mongod