log=/tmp/roboshop.log

func_apppreq(){

  echo -e "\e[36m >>>>>> Create ${component} Service  <<<<<<\e[0m"
  cp ${component}.service /etc/systemd/system/${component}.service &>>${log}

  echo -e "\e[36m >>>>>> Create Application User <<<<<<\e[0m" | tee -a /tmp/roboshop.log
  useradd roboshop &>>${log}

  echo -e "\e[36m >>>>>> Clean Existing Application Content <<<<<<\e[0m" | tee -a /tmp/roboshop.log
  rm -rf /app &>>${log}

  echo -e "\e[36m >>>>>> Create Application Directory <<<<<<\e[0m" | tee -a /tmp/roboshop.log
  mkdir /app &>>${log}

  echo -e "\e[36m >>>>>> Download Application Content <<<<<<\e[0m" | tee -a /tmp/roboshop.log
  curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log}

  echo -e "\e[36m >>>>>> Extract Application Content <<<<<<\e[0m" | tee -a /tmp/roboshop.log
  cd /app
  unzip /tmp/${component}.zip &>>${log}
  cd /app
}

func_systemd() {
    echo -e "\e[36m >>>>>> Start ${component} Service <<<<<<\e[0m" | tee -a /tmp/roboshop.log
    systemctl daemon-reload &>>${log}
    systemctl enable ${component} &>>${log}
    systemctl restart ${component} &>>${log}
}

func_nodejs() {
  log=/tmp/roboshop.log

  echo -e "\e[36m >>>>>> Create MongoDB Repo <<<<<<\e[0m" | tee -a /tmp/roboshop.log
  cp mongo.repo /etc/yum.repos.d/mongo.repo &>>${log}

  echo -e "\e[36m >>>>>> Install NodeJS Repos <<<<<<\e[0m" | tee -a /tmp/roboshop.log
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log}

  echo -e "\e[36m >>>>>> Install NodeJS <<<<<<\e[0m" | tee -a /tmp/roboshop.log
  yum install nodejs -y &>>${log}

  func_apppreq

  echo -e "\e[36m >>>>>> Download NodeJS Dependencies <<<<<<\e[0m" | tee -a /tmp/roboshop.log
  npm install &>>${log}

  echo -e "\e[36m >>>>>> Install MongoDB Client <<<<<<\e[0m" | tee -a /tmp/roboshop.log
  yum install mongodb-org-shell -y &>>${log}

  echo -e "\e[36m >>>>>> Load Schema <<<<<<\e[0m" | tee -a /tmp/roboshop.log
  mongo --host mongodb.kdevops72.online </app/schema/${component}.js &>>${log}

  func_systemd
}

func_java() {


  echo -e "\e[36m >>>>>> Install Maven  <<<<<<\e[0m"
  yum install maven -y &>>${log}

  func_apppreq

  echo -e "\e[36m >>>>>> Build ${component} Service  <<<<<<\e[0m"
  mvn clean package &>>${log}
  mv target/${component}-1.0.jar ${component}.jar &>>${log}

  echo -e "\e[36m >>>>>> Install MySQL Client  <<<<<<\e[0m"
  yum install mysql -y &>>${log}

  echo -e "\e[36m >>>>>> Load Schema  <<<<<<\e[0m"
  mysql -h mysql.kdevops72.online -uroot -pRoboShop@1 < /app/schema/${component}.sql &>>${log}

  func_systemd
}

func_python() {
  echo -e "\e[36m >>>>>> Build ${component} Service  <<<<<<\e[0m"
  yum install python36 gcc python3-devel -y &>>${log}

  func_apppreq

  echo -e "\e[36m >>>>>> Download Python Dependencies  <<<<<<\e[0m"
  pip3.6 install -r requirements.txt &>>${log}

  func_systemd
}

func_dispatch() {
  echo -e "\e[36m >>>>>> Install GoLang  <<<<<<\e[0m"
  yum install golang -y &>>${log}

  func_apppreq

  echo -e "\e[36m >>>>>> Download Dependencies  <<<<<<\e[0m"
  go mod init dispatch &>>${log}
  go get &>>${log}
  go build &>>${log}

  func_systemd
}