#!/bin/bash

#-----Sets up IAM, VPC on AWS-------------------------------------

set -e

# TODO - parametize the AWS region and user for script execution
# NOTE: Use AWS object tags as follows: "show":"ndc" in the 'ap-southeast-2' (Sydney) region

# Create IAM User and Role w/ permissions on S3, EC2, Redshift
warehouseUser = 'aws iam create-user ....'
echo warehouseUser $warehouseUser created

# Assign permission via AWS Policy associated to IAM user - needs S3, EC2, Redshift
# TODO

#Create a VPC
vpcId=`aws ec2 create-vpc --cidr-block 10.0.0.0/16 | jq .Vpc.VpcId -r`
echo vpc $vpcId created

#Create a subnet
subnetid=`aws ec2 create-subnet --vpc-id $vpcId --cidr-block 10.0.0.0/16| jq .Subnet.SubnetId -r`
echo subnet $subnetid created

#Create an Internet gateway
gatewayid=`aws ec2 create-internet-gateway| jq .InternetGateway.InternetGatewayId -r`
echo gateway $gatewayid created

#Attach internet gateway
aws ec2 attach-internet-gateway --internet-gateway-id  $gatewayid --vpc-id  $vpcId

#Add default route to route table.
routetableId=`aws ec2 describe-route-tables | jq .RouteTables[0].RouteTableId -r`
echo route table $routetableId found
aws ec2 create-route --route-table-id $routetableId --destination-cidr-block 0.0.0.0/0 --gateway-id $gatewayid

#Add redshift rule into the security group
securityGroupId=`aws ec2 describe-security-groups --filters Name=vpc-id,Values=$vpcId | jq .SecurityGroups[0].GroupId -r`
aws ec2 authorize-security-group-ingress --group-id $securityGroupId  --protocol tcp --port 5439 --cidr 10.0.0.0/16

#Create a public S3 data bucket
demoBucket='aws s3 mb s3://ndc-demo'
echo demoBucket $demoBucket created

##END SCRIPT