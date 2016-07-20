#!/bin/bash

set -e

#------Sets up YellowFin from AWS Marketplace on AWS EC2------------

REGION = 'ap-southeast-2'
MYKEYPAIR = '< my key >' #use a profile, not a key!

VPCID=`aws ec2 describe-vpc --region $REGION`
SUBNETID=`aws ec2 describe-subnet --region $REGION`
ROUTETABLEID=`aws ec2 describe-route-tables --region $REGION`
GATEWAYID='aws ec2 describe-gateways --region $REGION'
IPALLOCATIONID=`aws ec2 allocate-address --domain vpc --region $REGION`
aws ec2 create-route --route-table-id $ROUTETABLEID --destination-cidr-block 0.0.0.0/0 --gateway-id $GATEWAYID

# Add YellowFin rule(s) into the security group and TODO - needs rule for SSH (20), HTTP/S (80/443)
SECURITYGROUPID=`aws ec2 describe-security-groups --filters Name=vpc-id,Values=$VPCID`
aws ec2 authorize-security-group-ingress --group-id $SECURITYGROUPID  --protocol tcp --port 5439 --cidr 10.0.0.0/16

AMIYELLOWFIN = 'ami-209ebd43'  # this is for Australia region
INSTANCEID=`aws ec2 run-instances --image-id $AMIYELLOWFIN --count 1 --instance-type m3.large \
    --key-name $MYKEYPAIR --security-group-ids $SECURITYGROUPID --subnet-id $SUBNETID`
aws ec2 associate-address --instance-id $INSTANCEID --allocation-id $IPALLOCATIONID

# TODO - Pattern to add tags to resources
aws ec2 create-tags --resources ami-<value> i-<value> --tags Key=show,Value=ndc

# Connect to the Redshift Cluster
# TODO

# Use a YellowFin template File to produce a dashboard
# TODO - get template

