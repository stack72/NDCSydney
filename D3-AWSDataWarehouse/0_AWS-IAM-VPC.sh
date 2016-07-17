#!/bin/bash

set -e

#-----Sets up IAM, VPC on AWS-------------------------------------

REGION = 'ap-southeast-2'

WAREHOUSEUSER = 'aws iam create-user --user-name 'WAREHOUSEUSER''
WAREHOUSEROLE = 'aws iam create-role --role-name 'WAREHOUSEROLE''
WAREHOUSEPOLICY = 'aws iam create-policy --policy-name 'WAREHOUSEPOLICY' \
    --policy-document file://warehousePolicy.json --set-as-default' 
aws iam attach-user-policy --policy-arn $WAREHOUSEPOLICY --user-name $WAREHOUSEUSER
aws iam attach-role-policy --policy-arn $WAREHOUSEPOLICY --role-name $WAREHOUSEROLE

VPCID=`aws ec2 create-vpc --cidr-block 10.0.0.0/16 | jq .Vpc.VpcId -r`
SUBNETID=`aws ec2 create-subnet --vpc-id $vpcId --cidr-block 10.0.0.0/16| jq .Subnet.SubnetId -r`
GATEWAYID=`aws ec2 create-internet-gateway| jq .InternetGateway.InternetGatewayId -r`
aws ec2 attach-internet-gateway --internet-gateway-id  $GATEWAYID --vpc-id  $VPCID

ROUTETABLEID=`aws ec2 describe-route-tables | jq .RouteTables[0].RouteTableId -r`
aws ec2 create-route --route-table-id $ROUTETABLEID --destination-cidr-block 0.0.0.0/0 --gateway-id $GATEWAYID

SECURITYGROUPID=`aws ec2 describe-security-groups --filters Name=vpc-id,Values=$VPCID | jq .SecurityGroups[0].GroupId -r`
aws ec2 authorize-security-group-ingress --group-id $SECURITYGROUPID  --protocol tcp --port 5439 --cidr 10.0.0.0/16

DEMOBUCKET='aws s3 mb s3://ndc-demo'

