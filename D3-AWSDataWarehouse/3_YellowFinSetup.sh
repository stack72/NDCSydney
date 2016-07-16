#!/bin/bash

set -e

#------Sets up YellowFin from AWS Marketplace on AWS EC2)------------

REGION = 'ap-southeast-2'
MYKEYPAIR = ''

# TIP: Create IAM Group (and Users) with appropriate permissions prior to running this script
# User permissions needed are as follows: AWS S3, AWS Redshift, AWS EC2, AWS Marketplace

VPCID=`aws ec2 describe-vpc --region $REGION`
SUBNETID=`aws ec2 describe-subnet --region $REGION`
ROUTETABLEID=`aws ec2 describe-route-tables | jq .RouteTables[0].RouteTableId -r`
aws ec2 create-route --route-table-id $routetableId --destination-cidr-block 0.0.0.0/0 --gateway-id $gatewayid

# Add YellowFin rule(s) into the security group
# TODO - needs rule for SSH (20), HTTP/S (80/443)
securityGroupId=`aws ec2 describe-security-groups --filters Name=vpc-id,Values=$vpcId | jq .SecurityGroups[0].GroupId -r`
aws ec2 authorize-security-group-ingress --group-id $securityGroupId  --protocol tcp --port 5439 --cidr 10.0.0.0/16

# Launch YelloFin EC2 Instance from the AWS Marketplace using AMI for Australia
# Use the AMI from your region for YelloFin from the marketplace 
echo instance-id=`aws ec2 run-instances --image-id ami-209ebd43 --count 1 --instance-type m3.large \
    --key-name MyKeyPair --security-group-ids $securityGroupId --subnet-id $subnetid`
echo $instance-id

# TODO - Pattern to add tags to resources
aws ec2 create-tags --resources ami-<value> i-<value> --tags Key=show,Value=ndc

# Add an Elastic IP
echo ipAddress=`aws ec2 allocate-address --domain vpc | jq -r .PublicIp`
echo $ipAddress
echo $allocation-id

# Attach the Elastic IP to the YelloFin  Instance
# TOVERIFY
aws ec2 associate-address --instance-id $instance-id --allocation-id $allocation-id

# Connect to the Redshift Cluster
# TODO

# Use a YellowFin template File to produce a dashboard
# TODO - get template

##END SCRIPT