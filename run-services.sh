#!/bin/sh

shutdown_awslogs()
{
    echo "Stopping container..."
    kill $(pgrep -f /var/awslogs/bin/aws)
    exit 0
}

trap shutdown_awslogs INT TERM HUP

REGION=${AWS_REGION:-"eu-west-1"}

cp -f /awslogs.conf.dummy /var/awslogs/etc/awslogs.conf

cp -f /aws.conf.dummy /var/awslogs/etc/aws.conf

if [ "${AWS_ACCESS_KEY_ID}" = "" ] || [ "${AWS_SECRET_ACCESS_KEY}" = "" ]; then

cat >> /var/awslogs/etc/aws.conf <<EOF
region = ${REGION}

EOF

else

cat >> /var/awslogs/etc/aws.conf <<EOF
region = ${REGION}
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}

EOF

fi

mkdir ~/.aws

cat >> ~/.aws/config <<EOF
[default]
region=${REGION}

EOF

/configure-awslogs.sh

echo "AWS log config is:"
cat /var/awslogs/etc/awslogs.conf

/usr/sbin/cron

/run-awslogs-agent.sh &

wait
