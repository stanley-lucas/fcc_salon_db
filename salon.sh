#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ BEAUTY SALON ~~~~~\n"
echo -e "Welcome to the Beauty Salon, how can I help you?\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Please, type in a valid number. How can I help you?"
  else
    SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE ]]
    then 
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nIt looks like it's your first time here. What's your name?"
        read CUSTOMER_NAME
        ADD_CUSTOMER=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi
      
      echo -e "\nWhat time would you like your $(echo $SERVICE | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')?"
      read SERVICE_TIME
      
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      ADD_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

      echo -e "\nI have put you down for a $(echo $SERVICE | sed -E 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
    fi
  fi

}

MAIN_MENU