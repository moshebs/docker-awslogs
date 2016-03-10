## Dockerfile to run AWS CloudWatch Logs container

### Usage

This container is intended to upload logfiles to Amazon CloudWatch Logs service.
If you don't set any environment variables, container will start with the following config:

```
[/mnt/logs/access.log]
datetime_format = %d/%b/%Y:%H:%M:%S %z
file = /mnt/logs/access.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = nginx-server
```

### Environment variables

* `AWS_LOGFILE` default is "/mnt/logs/access.log"
* `AWS_LOGFORMAT` default is "%d/%b/%Y:%H:%M:%S %z"
* `AWS_DURATION` default is "5000"
* `AWS_GROUPNAME` default is "nginx-server"
* `AWS_LOG_STREAM_NAME` default is the EC2 instance ID
* `AWS_LOG_GROUP_RETENTION_POLICY_DAYS` default is 90 days. Allowed values are documented [here](http://docs.aws.amazon.com/cli/latest/reference/logs/put-retention-policy.html)
* `AWS_REGION` default is "eu-west-1"
* `AWS_ACCESS_KEY_ID` no default
* `AWS_SECRET_ACCESS_KEY` no default

### Example

```
# Run container with Nginx
docker run -d --name nginx -v /mnt/logs:/var/log/nginx -p 80:80 sergeyzh/centos6-nginx

# Run container with AWS CloudWatch logs uploader
docker run -d --name awslogs -e AWS_LOGFILE=/mnt/logs/access.log -e AWS_DURATION=10000 -e "AWS_SECRET_ACCESS_KEY=mYsEcReTaCcEsSkEy" -e "AWS_ACCESS_KEY_ID=MYACCESSKEYID" -v /mnt/logs:/mnt/logs sergeyzh/awslogs
```

Now you can see access logs of your Nginx at [AWS Console](https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logs:). 

NOTE: Of course you should run it on the Amazon EC2 and you should set IAM role for you instance according [manual](http://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/QuickStartEC2Instance.html).

### MAINTAINERS

* Ryuta Otaki <otaki.ryuta@classmethod.jp>
* Sergey Zhukov <sergey@jetbrains.com>
