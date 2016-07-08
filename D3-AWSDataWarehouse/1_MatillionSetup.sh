#!/bin/bash

#------Sets up Matillion ETL on AWS EC2)-------------------------

set -e

#TIP: Create IAM Group (and Users) with appropriate permissions prior to running this script
#User permissions needed are as follows: AWS S3, AWS Redshift, AWS EC2, AWS Marketplace

#Use the VPC
vpcId=`aws ec2 create-vpc --cidr-block 10.0.0.0/16 | jq .Vpc.VpcId -r`
echo vpc $vpcId created

#Use the subnet
subnetid=`aws ec2 create-subnet --vpc-id $vpcId --cidr-block 10.0.0.0/16| jq .Subnet.SubnetId -r`
echo subnet $subnetid created

#Use the Internet gateway
gatewayid=`aws ec2 create-internet-gateway| jq .InternetGateway.InternetGatewayId -r`
echo gateway $gatewayid created


#Launch Matillion EC2 Instance from the AWS Marketplace for the Australia region
# TOVERIFY - must use the AMI from your region for Matillion from the marketplace
echo instance-id=`aws ec2 run-instances --image-id 	ami-817e56e2 --count 1 --instance-type m3.large --key-name MyKeyPair --security-group-ids $securityGroupId --subnet-id $subnetid`
echo $instance-id

# TODO - Pattern to add tags to resources
aws ec2 create-tags --resources ami-<value> i-<value> --tags Key=show,Value=ndc

#Add an Elastic IP
echo ipAddress=`aws ec2 allocate-address --domain vpc | jq -r .PublicIp`
echo $ipAddress
echo $allocation-id

#Attach the Elastic IP to the Matillion Instance
# TOVERIFY
aws ec2 associate-address --instance-id $instance-id --allocation-id $allocation-id

#Create/alter a security group
# TODO

#Add Matillion rule into the security group
#fix this
securityGroupId=`aws ec2 describe-security-groups --filters Name=vpc-id,Values=$vpcId | jq .SecurityGroups[0].GroupId -r`
aws ec2 authorize-security-group-ingress --group-id $securityGroupId  --protocol tcp --port 5439 --cidr 10.0.0.0/16

#Load Data into Redshift via Matillion using data in public S3 bucket
# TODO
# NOTE: Import an existing Matillion package?

##END SCRIPT