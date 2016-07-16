
#!/bin/bash

#-----Sets up Redshift on AWS EC2)-------------------------------------

set -e
REGION = 'ap-southeast-2'

# TIP: Create IAM Group (and Users) with appropriate permissions prior to running this script
# User permissions needed are as follows: AWS S3, AWS Redshift, AWS EC2

VPCID=`aws ec2 describe-vpc --region $REGION`
SUBNETID=`aws ec2 describe-subnet --region $REGION`
ROUTETABLEID=`aws ec2 describe-route-tables | jq .RouteTables[0].RouteTableId -r`
GATEWAYID=`aws ec2 create-internet-gateway| jq .InternetGateway.InternetGatewayId -r`

#Add default route to route table.
aws ec2 create-route --route-table-id $routetableId --destination-cidr-block 0.0.0.0/0 --gateway-id $GATEWAYID

#Add redshift rule into the security group
securityGroupId=`aws ec2 describe-security-groups --filters Name=vpc-id,Values=$VPCID | jq .SecurityGroups[0].GroupId -r`
aws ec2 authorize-security-group-ingress --group-id $securityGroupId  --protocol tcp --port 5439 --cidr 10.0.0.0/16

# AWS REDSHIFT

#Create a Redshift cluster subnet grp
echo create the cluster subnet group
aws redshift create-cluster-subnet-group --cluster-subnet-group-name mysubnetgroup  --description "My subnet group" --subnet-ids $subnetid

#Create the Redshift cluster
echo redshiftid =`aws redshift create-cluster --node-type dc1.large  --master-username admin --master-user-password Password1 --cluster-type single-node --cluster-identifier My-Redshift-Cluster --db-name redshift --cluster-subnet-group-name mysubnetgroup | jq .Cluster.ClusterIdentifier -r`
echo created $redshiftid

#Create/alter a security group
redshiftSecurityGroup='aws redshift create-cluster-security-group'...
echo created $redshiftSecurityGroup

# TODO - Pattern to add tags to resources
aws redshift create-tags --resources ami-<value> i-<value> --tags Key=show,Value=ndc

#Access the public S3 data bucket
# TODO



##END SCRIPT