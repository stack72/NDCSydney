#!/bin/bash

set -e

#------Sets up Matillion ETL on AWS EC2)-------------------------

REGION = 'ap-southeast-2'
MYKEYPAIR = ''

VPCID=`aws ec2 describe-vpc --region $REGION`
SUBNETID=`aws ec2 describe-subnet --region $REGION`
ROUTETABLEID=`aws ec2 describe-route-tables`
SECURITYGROUPID='aws ec2 describe-security-groups'

# Add an Elastic IP
IPADDRESS=`aws ec2 allocate-address --domain vpc | jq -r .PublicIp`
echo $allocation-id

# Launch Matillion EC2 Instance from the AWS Marketplace for the Australia region
# TOVERIFY - must use the AMI from your region for Matillion from the marketplace
INSTANCEID=`aws ec2 run-instances --image-id 	ami-817e56e2 --count 1 --instance-type m3.large \
    --key-name $MYKEYPAIR --security-group-ids $SECURITYGROUPID --subnet-id $SUBNETID`

# Attach the Elastic IP to the Matillion Instance
# TOVERIFY
aws ec2 associate-address --instance-id $INSTANCEID--allocation-id $allocation-id

# TODO - Pattern to add tags to resources
DEMOTAGS='aws ec2 create-tags --resources ami-<value> i-<value> --tags Key=show,Value=ndc'

# Create/alter a security group
# TODO

# Add Matillion rule into the security group
aws ec2 authorize-security-group-ingress --group-id $securityGroupId  --protocol tcp --port 5439 --cidr 10.0.0.0/16

# Load Data into Redshift via Matillion using data in public S3 bucket
# TODO
# NOTE: Import an existing Matillion package?

