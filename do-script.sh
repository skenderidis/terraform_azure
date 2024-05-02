#!/bin/bash

# Set variables
BIGIP_IP="$TF_VAR_bigip_ip"
URL="https://${TF_VAR_bigip_ip}/mgmt/shared/declarative-onboarding"
AUTH="$TF_VAR_username:$TF_VAR_password"
JSON_FILE="$TF_VAR_json_file"
PREFIX="$TF_VAR_prefix"

start_time=$(date +%s)  # Get the start time
echo "Sending Declaration"
echo $URL
echo $JSON_FILE
# Send initial request with basic authentication
HTTP_CODE=$(curl -ks --output ${PREFIX}-temp.json --write-out '%{http_code}' -u "$AUTH" --header 'Content-Type: application/json' --data @"$JSON_FILE" --request POST $URL)

if [[ ${HTTP_CODE} -ne 202 ]]; then
  echo "ERROR - ${HTTP_CODE}"
  echo "Deployment Failed"
  cat "${PREFIX}-temp.json"
  exit 1
else
  id=$(cat "${PREFIX}-temp.json" | jq -r '.id')
  echo "HTTP_CODE - ${HTTP_CODE}"
  echo "Deployment for ${PREFIX} has been accepted."
  echo "30 seconds sleep"
  sleep 3
  echo "Poll F5 BIGIP every 5 seconds to get the status of the DO jobID. The ID is $id"
  
  # Initialize the status
  status="RUNNING"
  # Initialize the loop counter
  count=1
  do_status='https://'${BIGIP_IP}'/mgmt/shared/declarative-onboarding/task/'$id
  echo "Getting into a Loop to check DO status"
  # Loop until the status is different than "RUNNING" or a timeout occurs
  while [ "$status" == "RUNNING" ] && [ $count -lt 10 ]; do
    echo "Sending Request #"$count;
    # Send the curl GET request to check the status of the policy creation
    response=$(curl -ks -u "$AUTH" $do_status)
    
    status=$(echo "$response" | jq -r '.result.status') # Extract the "status" and "id" from the JSON response using jq
    code=$(echo "$response" | jq -r '.result.code') # Extract the "status" and "id" from the JSON response using jq

    echo "Current status -  $status" # Print the current status
    #echo "Retry ($count)"
    let "count++"   # Increment the loop counter
    echo "Sleep for 5 sec"
    if [ "$status" == "RUNNING" ]; then
      sleep 5    # Sleep for a few seconds before checking again
    fi
  done
  
  # When the loop exits, the status is "COMPLETED" or a timeout occurred
  if [ "$status" != "OK" ]; then
    echo "Timeout occurred after 10 retries."
    echo $response | jq .
    # You can add additional error handling here if needed
  else
    echo "DO Completed successfully"
    end_time=$(date +%s) # Get the end time
    elapsed_time=$((end_time - start_time)) # Calculate the elapsed time
    echo "Time elapsed: $elapsed_time seconds" # Print the elapsed time
  fi
fi