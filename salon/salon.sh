#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"

SERVICE_MENU(){
  echo "$1" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  echo "4) Exit"
}

EXIT() {
  echo -e "\nThank you for stopping in.\n"
}

echo -e "Welcome to My Salon, how can I help you?\n"
SERVICE_LIST=$($PSQL "select service_id, name from services")
SERVICE_MENU "$SERVICE_LIST"

while true
do
  read SERVICE_ID_SELECTED
  if [[ $SERVICE_ID_SELECTED == 4 ]]
  then
    EXIT
    break
  fi
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    echo -e "\nI could not find that service. What would you like today?"
    SERVICE_MENU "$SERVICE_LIST"
    continue
  else
    SERVICE_ID=$($PSQL "select service_id from services where service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_ID ]]
    then
      echo -e "\nThat's not in our services. What would you like today?"
      SERVICE_MENU "$SERVICE_LIST"
    else
      break
    fi
  fi
done

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
SERVICE_NAME=$($PSQL "select name from services where service_id='$SERVICE_ID'")
if [[ -z $CUSTOMER_ID ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  INSERT_NAME=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
else
  CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")
fi
echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed 's/^ *| *$//g')?"
read SERVICE_TIME

echo -e "\nI have put you down for a cut at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/^ *| *$//g')."

INSERT_TO_APPOINTMENT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")


