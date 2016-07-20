#!/bin/bash

set -e

#------Sets up Matillion ETL on AWS EC2)-------------------------

REGION = 'ap-southeast-2'
MYKEYPAIR = '< my key >' #use a profile, not a key!

VPCID=`aws ec2 describe-vpc --region $REGION`
SUBNETID=`aws ec2 describe-subnet --region $REGION`
ROUTETABLEID=`aws ec2 describe-route-tables`
SECURITYGROUPID='aws ec2 describe-security-groups'
IPALLOCATIONID=`aws ec2 allocate-address --domain vpc --region $REGION`
AMIMATILLION = 'ami-817e56e2' #for Australia region

INSTANCEID=`aws ec2 run-instances --image-id $AMIMATILLION --count 1 --instance-type m3.large \
    --key-name $MYKEYPAIR --security-group-ids $SECURITYGROUPID --subnet-id $SUBNETID`
aws ec2 associate-address --instance-id $INSTANCEID --allocation-id $IPALLOCATIONID

# TODO - Pattern to add tags to resources
DEMOTAGS='aws ec2 create-tags --resources ami-<value> i-<value> --tags Key=show,Value=ndc'

# Create/alter a security group - TODO
aws ec2 authorize-security-group-ingress --group-id $SECURITYGROUPID  --protocol tcp --port 5439 --cidr 10.0.0.0/16

# Load Data into Redshift via Matillion using data in public S3 bucket
# TODO
# NOTE: Import an existing Matillion package?

