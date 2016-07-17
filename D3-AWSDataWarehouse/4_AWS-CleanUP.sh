
#!/bin/bash

set -e

#-----Removes all demo resources-------------------------------------

REGION = 'ap-southeast-2'
ACCOUNT = '653004187743'
# TODO - scrub account value
# ACCOUNT = <your AWS account number>

# TODO - Determine and update 'destruction order' of objects

aws iam delete-user --user-name 'WAREHOUSEUSER'
aws iam delete-role --role-name 'WAREHOUSEROLE'
aws iam delete-policy --policy-arn 'arn:aws:iam::$ACCOUNT:policy/WAREHOUSEPOLICY'

ROUTETABLEID=`aws ec2 describe-route-tables --region $REGION`
aws ec2 delete-route --route-table-id $ROUTETABLEID --destination-cidr-block 0.0.0.0/0 --gateway-id $INTERNETGATEWAYID

INTERNETGATEWAYID='aws ec2 describe-internet-gateways --region $REGION'
aws ec2 detach-internet-gateway --internet-gateway-id  $INTERNETGATEWAYID --vpc-id  $VPCID
aws ec2 delete-internet-gateway --internet-gateway-id  $INTERNETGATEWAYID 

VPCID=`aws ec2 describe-vpcs --region $REGION`
aws ec2 delete-vpc --vpc-id $VPCID

SUBNETID=`aws ec2 describe-subnets --region $REGION`
aws ec2 delete-subnet --subnet-id $SUBNETID

# TODO -- Delete redshift rule into the security group - TO:'unauthorize'
SECURITYGROUPID=`aws ec2 describe-security-groups --filters Name=vpc-id,Values=$VPCID | jq .SecurityGroups[0].GroupId -r`
aws ec2 authorize-security-group-ingress --group-id $SECURITYGROUPID  --protocol tcp --port 5439 --cidr 10.0.0.0/16

# Find EC2 tagged instances and delete them (Matillion, YellowFin)
aws ec2 describe-instances --resources ami-<value> i-<value> --tags Key=show,Value=ndc --region $REGION
aws ec2 terminate-instances ....

# Find Redshift cluster tagged instances and delete them
redshiftCluster='aws redshift describe-instances --resources ami-<value> i-<value> --tags Key=show,Value=ndc'
aws redshift delete-cluster ....

# TODO - Delete non-empty public S3 data bucket
aws s3 rb s3://<bucketName> <tag>.... --force

