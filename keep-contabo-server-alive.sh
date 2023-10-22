#!/bin/bash

if [ "$#" -ne 6 ]; then
  echo "Usage: $0 <server_to_ping> <client_id> <client_secret> <username> <password> <instance_id>"
  exit 1
fi

server_to_ping="$1"
client_id="$2"
client_secret="$3"
username="$4"
password="$5"
instance_id="$6"

# Debug: Print out all the parameters
echo "Parameters:"
echo "Server to Ping: $server_to_ping"
echo "Client ID: $client_id"
echo "Client Secret: $client_secret"
echo "Username: $username"
echo "Password: $password"
echo "Instance ID: $instance_id"


ping -c 4 $server_to_ping

if [ $? -ne 0 ]; then
  echo "Server is down. Restarting it..."
  ACCESS_TOKEN=$(curl --location 'https://auth.contabo.com/auth/realms/contabo/protocol/openid-connect/token' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--header 'Cookie: KEYCLOAK_LOCALE=en' \
--data-urlencode "client_id=$client_id" \
--data-urlencode "client_secret=$client_secret" \
--data-urlencode "grant_type=password" \
--data-urlencode "username=$username" \
--data-urlencode "password=$password" | jq -r '.access_token')
# restart instance
curl -X POST -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "x-request-id: 04e0f898-37b4-48bc-a794-1a57abe6aa31" -H  "x-trace-id: 123213" "https://api.contabo.com/v1/compute/instances/$instance_id/actions/restart"
else
  echo "Server is up."
fi
