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

/configure-awslogs.sh

echo "AWS log config is:"
cat /var/awslogs/etc/awslogs.conf

/var/awslogs/bin/awslogs-agent-launcher.sh &

wait
