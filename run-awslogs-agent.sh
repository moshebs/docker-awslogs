#!/bin/sh

while true; do
	/var/awslogs/bin/awslogs-agent-launcher.sh &
	wait
done
