FROM ubuntu:latest
MAINTAINER Ryuta Otaki <otaki.ryuta@classmethod.jp>, Sergey Zhukov <sergey@jetbrains.com>

RUN apt-get update
RUN apt-get install -q -y python python-pip wget
RUN cd / ; wget https://s3.amazonaws.com/aws-cloudwatch/downloads/awslogs-agent-setup-v1.0.py

ADD awslogs.conf.dummy /
RUN python /awslogs-agent-setup-v1.0.py -n -r eu-west-1 -c ./awslogs.conf.dummy
# ONBUILD ADD aws.conf       /var/awslogs/etc/aws.conf
# ONBUILD ADD awslogs.conf /var/awslogs/etc/awslogs.conf

ADD run-services.sh /
RUN chmod a+x /run-services.sh
CMD /run-services.sh
