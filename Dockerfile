FROM ubuntu:16.04
MAINTAINER Ryuta Otaki <otaki.ryuta@classmethod.jp>, Sergey Zhukov <sergey@jetbrains.com>

RUN apt-get update
RUN apt-get install logrotate
RUN apt-get install -q -y python python-pip wget
RUN cd / ; wget https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py
RUN pip install awscli --ignore-installed six

ADD awslogs.conf.dummy /
ADD aws.conf.dummy /
RUN mkdir /etc/cron.d
RUN python /awslogs-agent-setup.py -n -r us-east-1 -c ./awslogs.conf.dummy
# ONBUILD ADD aws.conf       /var/awslogs/etc/aws.conf
# ONBUILD ADD awslogs.conf /var/awslogs/etc/awslogs.conf

RUN sed -i /restart/d /etc/logrotate.d/awslogs

ADD run-services.sh /
ADD configure-awslogs.sh /
RUN chmod a+x /run-services.sh
CMD /run-services.sh
