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

LOG_FILE=${AWS_LOGFILE:-"/mnt/logs/access.log"}
LOG_FORMAT=${AWS_LOGFORMAT:-"%d/%b/%Y:%H:%M:%S %z"}
DURATION=${AWS_DURATION:-"5000"}
GROUP_NAME=${AWS_GROUPNAME:-"nginx-server"}
LOG_STREAM_NAME=${AWS_LOG_STREAM_NAME:-'{instance_id}'}
LOG_GROUP_RETENTION_POLICY_DAYS=${AWS_LOG_GROUP_RETENTION_POLICY_DAYS:-'90'}
REGION=${AWS_REGION:-"eu-west-1"}

cp -f /awslogs.conf.dummy /var/awslogs/etc/awslogs.conf

cp -f /aws.conf.dummy /var/awslogs/etc/aws.conf

cat >> /var/awslogs/etc/awslogs.conf <<EOF
[${LOG_FILE}]
datetime_format = ${LOG_FORMAT}
file = ${LOG_FILE}
buffer_duration = ${DURATION}
log_stream_name = ${LOG_STREAM_NAME}
initial_position = start_of_file
log_group_name = ${GROUP_NAME}

EOF

cat >> /var/awslogs/etc/aws.conf <<EOF
region = ${REGION}
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}

EOF

# Trying to create the log group so we can set a policy on it. It will simply fail if the 
# log group already exists
aws logs create-log-group $GROUP

# Set retention policy
aws logs put-retention-policy --log-group-name $GROUP --retention-in-days ${LOG_GROUP_RETENTION_POLICY_DAYS}

/var/awslogs/bin/awslogs-agent-launcher.sh &

wait
