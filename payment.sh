component=payment
source common.sh
rabbitmq_app_password=$1
if [ -z "${rabbitmq_app_passowrd}" ]; then
  echo INPUT RabbitMQ APP USER PASSWORD MISSING
  exit 1
fi
func_python