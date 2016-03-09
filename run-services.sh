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

LOGFILE=${AWS_LOGFILE:-"/mnt/logs/access.log"}
LOGFORMAT=${AWS_LOGFORMAT:-"%d/%b/%Y:%H:%M:%S %z"}
DURATION=${AWS_DURATION:-"5000"}
GROUPNAME=${AWS_GROUPNAME:-"nginx-server"}
LOGSTREAMNAME=${AWS_LOGSTREAMNAME:-'{instance_id}'}
REGION=${AWS_REGION:-"eu-west-1"}

echo $LOGSTREAMNAME > /var/awslogs/etc/debug.txt

cp -f /awslogs.conf.dummy /var/awslogs/etc/awslogs.conf

cp -f /aws.conf.dummy /var/awslogs/etc/aws.conf

cat >> /var/awslogs/etc/awslogs.conf <<EOF
[${LOGFILE}]
datetime_format = ${LOGFORMAT}
file = ${LOGFILE}
buffer_duration = ${DURATION}
log_stream_name = ${LOGSTREAMNAME}
initial_position = start_of_file
log_group_name = ${GROUPNAME}

EOF

cat >> /var/awslogs/etc/aws.conf <<EOF
region = ${REGION}
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}

EOF

/var/awslogs/bin/awslogs-agent-launcher.sh &

wait
