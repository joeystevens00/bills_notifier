# Bills Notifier

Sends an email notifying you that bills are due soon

## YAML

The notification config and bills are in YAML. 

### Config
```
config:
  date_format: dmy
  num_days_before_reminder: 1
  time_of_reminder: 23:10
  currency: $
 ```

_date_format_ : The format that dates in the YAML file use (d=day, m=month, y=year)  
_num_days_before_reminder_ : The number of days before the bill's due date when the email will be sent  
_time_of_reminder_ : The time of day that the reminders will be sent at.  
_currency_ : The currency symbol used that bill amount represents.  

### Bills

Each bill should be listed under the bills key with their own unique key (e.g. 1,2,3) with the keys 'name', 'description', 'amount', 'start_date', and 'frequency'. E.g.

```
bills:
  1:
    name: Chase
    description: |
      The bill to Chase
    amount: 50
    start_date: 05-05-2017
    frequency: weekly
```

_name_ : The name of the bill   
_description_ : A description of the bill    
_amount_ : The cost of the bill   
_start_date_ : An example due date of the bill. The format should match the format specified in date_format
_frequency_ : The frequency that the bill occurs (weekly or monthly)

## Env variables
The .env file needs to exist in config/.env with the variables
```
GMAIL_USERNAME = 'where_the_notifications_come_from@gmail.com'
GMAIL_PASSWORD = 'password'
BILLS_EMAIL = 'where_the_notifications_go@gmail.com'
BILL_NOTIFIER_ROOT_DIR='/path/to/bills_notifier'
```

## Install
After editing the YAML and .env files install the notifications by executing `bin/install_notifications.sh`