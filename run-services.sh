#!/bin/sh

shutdown_awslogs()
{
    echo "Stopping container..."
    kill $(pgrep -f /var/awslogs/bin/aws)
    exit 0
}

trap shutdown_awslogs INT TERM HUP


# [/mnt/logs/access.log]
# datetime_format = %d/%b/%Y:%H:%M:%S %z
# file = /mnt/logs/access.log
# buffer_duration = 5000
# log_stream_name = {instance_id}
# initial_position = start_of_file
# log_group_name = nginx-server   

add_log()
{   
	LOG_FILE_VAR_NAME=AWS_LOGFILE$1 
	LOG_FILE=${!LOG_FILE_VAR_NAME}
	if [ "$LOG_FILE" == "" ]; then
		return 0
	fi

	LOG_FORMAT_VAR_NAME=AWS_LOGFORMAT$1 
	LOG_FORMAT=${!LOG_FORMAT_VAR_NAME:-"%d/%b/%Y:%H:%M:%S %z"}
	
	DURATION_VAR_NAME=AWS_DURATION$1 
	DURATION=${!DURATION_VAR_NAME:-"5000"}
	
	GROUP_NAME_VAR_NAME=AWS_GROUPNAME$1 
	GROUP_NAME=${!GROUP_NAME_VAR_NAME:-"nginx-server"}
	
	LOG_STREAM_NAME_VAR_NAME=AWS_LOG_STREAM_NAME$1 
	LOG_STREAM_NAME=${!LOG_STREAM_NAME_VAR_NAME:-'{instance_id}'}
	
	LOG_GROUP_RETENTION_POLICY_DAYS_VAR_NAME=AWS_LOG_GROUP_RETENTION_POLICY_DAYS$1 
	LOG_GROUP_RETENTION_POLICY_DAYS=${!LOG_GROUP_RETENTION_POLICY_DAYS_VAR_NAME:-'90'}
	
cat >> /Users/mosheb/temp/logs/awslogs.conf <<EOF
[${LOG_FILE}]
datetime_format = ${LOG_FORMAT}
file = ${LOG_FILE}
buffer_duration = ${DURATION}
log_stream_name = ${LOG_STREAM_NAME}
initial_position = start_of_file
log_group_name = ${GROUP_NAME}

EOF
	
	# Trying to create the log group so we can set a policy on it. It will simply fail if the 
	# log group already exists
	aws logs create-log-group --log-group-name ${GROUP_NAME}

	# Set retention policy
	aws logs put-retention-policy --log-group-name ${GROUP_NAME} --retention-in-days ${LOG_GROUP_RETENTION_POLICY_DAYS}

	return 1
	
}	

REGION=${AWS_REGION:-"eu-west-1"}

cp -f /awslogs.conf.dummy /var/awslogs/etc/awslogs.conf

cp -f /aws.conf.dummy /var/awslogs/etc/aws.conf


cat >> /var/awslogs/etc/aws.conf <<EOF
region = ${REGION}
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}

EOF

mkdir ~/.aws

cat >> ~/.aws/config <<EOF
[default]
region=${REGION}

EOF

# Adding default log
add_log()

result=1
index=1

while [ "$result" == "1" ]
do
   result = add_log($index)
   index=`expr $index + 1`
done

/var/awslogs/bin/awslogs-agent-launcher.sh &

wait
