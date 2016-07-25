#!/bin/bash

set -e

#-----Sets up IAM, VPC on AWS-------------------------------------

REGION = 'ap-southeast-2'
PROFILE = 'demo-ndc'

WAREHOUSEUSER = 'aws iam create-user --user-name 'WAREHOUSEUSER''
WAREHOUSEROLE = 'aws iam create-role --role-name 'WAREHOUSEROLE''
# TODO - further limit the policy to the EC2 AMI images only and the S3 bucket only
WAREHOUSEPOLICY = 'aws iam create-policy --policy-name 'WAREHOUSEPOLICY' \
    --policy-document file://warehousePolicy.json --set-as-default' 
aws iam attach-user-policy --policy-arn $WAREHOUSEPOLICY --user-name $WAREHOUSEUSER
aws iam attach-role-policy --policy-arn $WAREHOUSEPOLICY --role-name $WAREHOUSEROLE

VPCID=`aws ec2 create-vpc --cidr-block 10.0.0.0/16`
SUBNETID1=`aws ec2 create-subnet --vpc-id $vpcId --cidr-block 10.0.0.0/28`
SUBNETID2=`aws ec2 create-subnet --vpc-id $vpcId --cidr-block 10.0.0.16/28`

GATEWAYID=`aws ec2 create-internet-gateway`
aws ec2 attach-internet-gateway --internet-gateway-id  $GATEWAYID --vpc-id  $VPCID
ROUTETABLEID=`aws ec2 describe-route-tables`
aws ec2 create-route --route-table-id $ROUTETABLEID --destination-cidr-block 0.0.0.0/0 --gateway-id $GATEWAYID

SECURITYGROUPID=`aws ec2 create-security-group --group-name NDC Name=vpc-id,Values=$VPCID`
aws ec2 authorize-security-group-ingress --group-id $SECURITYGROUPID  --cidr 10.0.0.0/16

DEMOBUCKET='aws s3 mb s3://ndc-demo'

