
#!/bin/bash

set -e

#-----Sets up Redshift on AWS EC2)-------------------------------------

REGION = 'ap-southeast-2'
MYKEYPAIR = ''

VPCID=`aws ec2 describe-vpc --region $REGION`
SUBNETID=`aws ec2 describe-subnet --region $REGION`
ROUTETABLEID=`aws ec2 describe-route-tables | jq .RouteTables[0].RouteTableId -r`
GATEWAYID=`aws ec2 create-internet-gateway| jq .InternetGateway.InternetGatewayId -r`

aws ec2 create-route --route-table-id $routetableId --destination-cidr-block 0.0.0.0/0 --gateway-id $GATEWAYID
SECURITYGROUPID=`aws ec2 describe-security-groups --filters Name=vpc-id,Values=$VPCID | jq .SecurityGroups[0].GroupId -r`
aws ec2 authorize-security-group-ingress --group-id $SECURITYGROUPID  --protocol tcp --port 5439 --cidr 10.0.0.0/16

# AWS REDSHIFT

#Create a Redshift cluster subnet grp
echo create the cluster subnet group
aws redshift create-cluster-subnet-group --cluster-subnet-group-name NDCDEMO  --description "NDCDEMO" --subnet-ids $SUBNETID

#Create the Redshift cluster
echo redshiftid =`aws redshift create-cluster --node-type dc1.large  --master-username admin --master-user-password Password1 \
    --cluster-type single-node --cluster-identifier My-Redshift-Cluster --db-name redshift \
    --cluster-subnet-group-name mysubnetgroup | jq .Cluster.ClusterIdentifier -r`
echo created $redshiftid

#Create/alter a security group
REDSHIFTSECURITYGROUP='aws redshift create-cluster-security-group'...

# TODO - Pattern to add tags to resources
aws redshift create-tags --resources ami-<value> i-<value> --tags Key=show,Value=ndc

#Access the public S3 data bucket
# TODO



##END SCRIPT