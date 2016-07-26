#!/bin/bash

set -e

#------Sets up YellowFin from AWS Marketplace on AWS EC2------------

REGION = 'ap-southeast-2'
MYKEYPAIR = '< my key >' 
VPCID=`aws ec2 describe-vpc --region $REGION`
SUBNETID=`aws ec2 describe-subnet --region $REGION`
IPALLOCATIONID=`aws ec2 allocate-address --domain vpc --region $REGION`

# Create security group and add inbound rules for rule for SSH (20), HTTP/S (80/443)
aws ec2 create-security-group --group-name NDC-Yellowfin Name=vpc-id,Values=$VPCID
aws ec2 authorize-security-group-ingress --group-id $SECURITYGROUPID  --protocol tcp --port 22 --cidr <your IP address>
aws ec2 authorize-security-group-ingress --group-id $SECURITYGROUPID  --protocol http --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SECURITYGROUPID  --protocol https --port 443 --cidr 0.0.0.0/0

AMIYELLOWFIN = 'ami-9c1338ff'  # this is for Australia region from AWS Marketplace
INSTANCEID=`aws ec2 run-instances --image-id $AMIYELLOWFIN --count 1 --instance-type m3.large \
    --key-name $MYKEYPAIR --security-group-ids $SECURITYGROUPID --subnet-id $SUBNETID`
aws ec2 associate-address --instance-id $INSTANCEID --allocation-id $IPALLOCATIONID

# TODO - Pattern to add tags to resources
aws ec2 create-tags --resources ami-<value> i-<value> --tags Key=show,Value=ndc

#Then open your public IP <http://<EC2-publicIP>, register your details to receive your log-in via email. 

# Connect to the Redshift Cluster - ADD an ingress rule to the security group for Redshift for YellowFin!
# TODO

#Login to Yellowfin, go to Admin>Dashboard>Data Sources, fill in Redshift info, click 'create view'

## Reference for connecting to Redshift -- http://wiki.yellowfin.com.au/display/USER72/Connecting+to+Redshift


# Use a YellowFin template File to produce a dashboard
# TODO - get template
## Reference for demo dashboards -- http://wiki.yellowfin.com.au/display/USER72/Getting+Started

