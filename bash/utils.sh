send_activity_message (){
  message=$1
  echo "$message" > /dev/udp/localhost/9000
}
