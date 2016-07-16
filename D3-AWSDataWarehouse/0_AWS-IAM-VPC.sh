#!/bin/bash

set -e

#-----Sets up IAM, VPC on AWS-------------------------------------

REGION = 'ap-southeast-2'
# NOTE: Use AWS object tags as follows: "show":"ndc" in the 'ap-southeast-2' (Sydney) region

# Create IAM User, Role and Policy and attach all
WAREHOUSEUSER = 'aws iam create-user ....  --region $REGION'
WAREHOUSEROLE = '...'
WAREHOUSEPOLICY = '...' #Use S3, EC2, AMI, Redshift
aws iam attach-user-policy --policy-arn $WAREHOUSEPOLICY --user-name $WAREHOUSEUSER
aws iam attach-role-policy --policy-arn $WAREHOUSEPOLICY --role-name $WAREHOUSEROLE

# Create a VPC, Subnet, Gateway
VPCID=`aws ec2 create-vpc --cidr-block 10.0.0.0/16 | jq .Vpc.VpcId -r`
SUBNETID=`aws ec2 create-subnet --vpc-id $vpcId --cidr-block 10.0.0.0/16| jq .Subnet.SubnetId -r`
GATEWAYID=`aws ec2 create-internet-gateway| jq .InternetGateway.InternetGatewayId -r`

#Attach internet gateway
aws ec2 attach-internet-gateway --internet-gateway-id  $GATEWAYID --vpc-id  $VPCID

#Add default route to route table.
ROUTETABLEID=`aws ec2 describe-route-tables | jq .RouteTables[0].RouteTableId -r`
aws ec2 create-route --route-table-id $ROUTETABLEID --destination-cidr-block 0.0.0.0/0 --gateway-id $GATEWAYID

#Add redshift rule into the security group
SECURITYGROUPID=`aws ec2 describe-security-groups --filters Name=vpc-id,Values=$VPCID | jq .SecurityGroups[0].GroupId -r`
aws ec2 authorize-security-group-ingress --group-id $SECURITYGROUPID  --protocol tcp --port 5439 --cidr 10.0.0.0/16

#Create a public S3 data bucket
DEMOBUCKET='aws s3 mb s3://ndc-demo'

##END SCRIPT