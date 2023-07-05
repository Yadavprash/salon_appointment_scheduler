#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~ Salon Appointment ~~~\n"

echo -e "Welcome to My Salon, What would you like get done?\n"

MAIN_MENU(){

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # get services
  SERVICES_RESULT=$($PSQL "SELECT * FROM SERVICES")
  echo "$SERVICES_RESULT" | while read SERVICE_ID BAR SERVICE_TYPE
  do
    echo -e "$SERVICE_ID) $SERVICE_TYPE"
  done
  # select the service
  read SERVICE_ID_SELECTED
  # if not a number 
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]+$ ]]
  then
    # return to main menu
    MAIN_MENU "Select from services 1 to 5."
  else
    #ask for phone number
    echo -e "\nEnter your phone number"
    read CUSTOMER_PHONE
    GET_CUSTOMER_DETAIL=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE'")
    #if phone number not in records
    if [[ -z $GET_CUSTOMER_DETAIL ]]
    then
      #add new customer
      echo "Please enter your name"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    fi
    SERVICE_TYPE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" )
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    echo "What time would you like your$SERVICE_TYPE,$CUSTOMER_NAME?"
    read SERVICE_TIME 
    # if service time is not correct
    # if [[ ! $SERVICE_TIME =~ ^([0-9]+:[0-9]+|[1-9]+pm)$ ]]
    # then
    #   # send to main menu
    #   MAIN_MENU "Please enter time in format like 10:30 or 7pm."
    # fi  
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

    echo "I have put you down for a$SERVICE_TYPE at $SERVICE_TIME,$CUSTOMER_NAME."
  fi
}



MAIN_MENU