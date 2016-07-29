
#!/bin/bash

set -e

#-----Removes all demo resources-------------------------------------

REGION = '< my AWS region >' # for Australia use 'ap-southeast-2'
ACCOUNT = '< my AWS account number >'

# TODO - Vaidate and update 'destruction order' of objects
# Terminate the instances - dissassociates elassticip automatically
# Terminiate the redshift instances
# Delete the redshift security group
# Remove the security (ingress) rules in the ndc security group
# Delete the security groups
# Release the elasticips
aws ec2 release-address --allocation-id <value1>
aws ec2 release-address --allocation-id <value2>
# Delete the VPC (deletes the route table, internet gateway and subnets)

# TODO -- Delete redshift, matillion and yellowfin rules into the main ndc security group - TO:'unauthorize'
SECURITYGROUPID=`aws ec2 describe-security-groups --filters Name=vpc-id,Values=$VPCID | jq .SecurityGroups[0].GroupId -r`
aws ec2 authorize-security-group-ingress --group-id $SECURITYGROUPID  --protocol tcp --port 5439 --cidr 10.0.0.0/16

# Find EC2 tagged instances and delete them (Matillion, YellowFin)
aws ec2 describe-instances --resources ami-<value> i-<value> --tags Key=show,Value=ndc --region $REGION
aws ec2 terminate-instances ....

# Find Redshift cluster tagged instances and delete them
redshiftCluster='aws redshift describe-instances --resources ami-<value> i-<value> --tags Key=show,Value=ndc'
aws redshift delete-cluster ....

ROUTETABLEID=`aws ec2 describe-route-tables --region $REGION`
aws ec2 delete-route --route-table-id $ROUTETABLEID --destination-cidr-block 0.0.0.0/0 --gateway-id $INTERNETGATEWAYID

INTERNETGATEWAYID='aws ec2 describe-internet-gateways --region $REGION'
aws ec2 detach-internet-gateway --internet-gateway-id  $INTERNETGATEWAYID --vpc-id  $VPCID
aws ec2 delete-internet-gateway --internet-gateway-id  $INTERNETGATEWAYID 

VPCID=`aws ec2 describe-vpcs --region $REGION`
aws ec2 delete-vpc --vpc-id $VPCID

SUBNETID=`aws ec2 describe-subnets --region $REGION`
aws ec2 delete-subnet --subnet-id $SUBNETID

# TODO - Delete non-empty public S3 data bucket
aws s3 rb s3://<bucketName> <tag>.... --force

aws iam delete-user --user-name 'WAREHOUSEUSER'
aws iam delete-role --role-name 'WAREHOUSEROLE'
aws iam delete-policy --policy-arn 'arn:aws:iam::$ACCOUNT:policy/WAREHOUSEPOLICY'

