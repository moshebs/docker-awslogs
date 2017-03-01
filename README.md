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

### Configuration

The container is configured using a set of environment variables.

#### Generic Configuration

The following environment variables are generic and used for all collected logs:

* `AWS_REGION` default is "eu-west-1"
* `AWS_ACCESS_KEY_ID` no default
* `AWS_SECRET_ACCESS_KEY` no default

#### Per-log configuration

The following environment variables are expected per log files you wish to collect. 

The variables are a concatenation of base variable name and an index running from 1 to n, where n is the number of log files you wish to collect.

The anchor variable is AWS_LOGFILE<X>, where <X> is 1,2,3 and so on. The configuration mechanism looks for these variables one after the other and stops at the first one it does not find (e.g. if you have AWS_LOGFILE1, AWS_LOGFILE2 and AWS_LOGFILE4, the last one is ignored).

Per log file, the other variables are optional.

* `AWS_LOGFILE<X>` - The log file to collect, default is "/mnt/logs/access.log"
* `AWS_LOGFORMAT<X>` - The datetime format of the log, default is "%d/%b/%Y:%H:%M:%S %z"
* `AWS_DURATION<X>` - Specifies the time duration for the batching of log events. The minimum value is 5000ms and default value is 5000ms.
* `AWS_GROUPNAME<X>` - Specifies the destination log group, default is "nginx-server"
* `AWS_LOG_STREAM_NAME<X>` - Specifies the destination log stream, default is the EC2 instance ID.
* `AWS_LOG_GROUP_RETENTION_POLICY_DAYS<X>` - The retention policy of the log group. This variable is takes effect if and only if the log group does not yet exist and is initialized by the log collecting container. The default is 90 days. Allowed values are documented [here](http://docs.aws.amazon.com/cli/latest/reference/logs/put-retention-policy.html)
* `AWS_MULTI_LINE_START_PATTERN<X>` - Specifies the pattern for identifying the start of a log message. The default value is ‘^[^\s]' so any line that begins with non-whitespace character closes the previous log message and starts a new log message.

### Example 

```
# Run container with Nginx
docker run -d --name nginx -v /mnt/logs:/var/log/nginx -p 80:80 sergeyzh/centos6-nginx

# Run container with AWS CloudWatch logs uploader
docker run -d --name awslogs -e AWS_LOGFILE1=/mnt/logs/access.log -e AWS_DURATION1=10000 -e AWS_LOGFILE2=/mnt/logs/app.log -e AWS_DURATION2=20000 -e "AWS_SECRET_ACCESS_KEY=mYsEcReTaCcEsSkEy" -e "AWS_ACCESS_KEY_ID=MYACCESSKEYID" -v /mnt/logs:/mnt/logs sergeyzh/awslogs
```

Now you can see access and app logs of your Nginx at [AWS Console](https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logs:). 

NOTE: Of course you should run it on the Amazon EC2 and you should set IAM role for you instance according [manual](http://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/QuickStartEC2Instance.html).

### Credits

Project was cloned from https://github.com/SergeyZh/docker-awslogs, which is maintained by:

* Ryuta Otaki <otaki.ryuta@classmethod.jp>
* Sergey Zhukov <sergey@jetbrains.com>
