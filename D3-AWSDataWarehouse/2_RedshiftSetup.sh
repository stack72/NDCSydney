
#!/bin/bash

set -e

#-----Sets up Redshift on AWS EC2)-------------------------------------

REGION = 'ap-southeast-2'
MYKEYPAIR = ''

VPCID=`aws ec2 describe-vpc --region $REGION`
SUBNETID=`aws ec2 describe-subnet --region $REGION`
ROUTETABLEID=`aws ec2 describe-route-tables --region $REGION`
GATEWAYID=`aws ec2 create-internet-gateway --region $REGION`

aws ec2 create-route --route-table-id $ROUTETABLEID --destination-cidr-block 0.0.0.0/0 --gateway-id $GATEWAYID
SECURITYGROUPID=`aws ec2 describe-security-groups --filters Name=vpc-id,Values=$VPCID`
aws ec2 authorize-security-group-ingress --group-id $SECURITYGROUPID  --protocol tcp --port 5439 --cidr 10.0.0.0/16

SUBNETGROUP = aws redshift create-cluster-subnet-group --cluster-subnet-group-name "ndcdemo" \
    --description "ndcdmo" --subnet-ids $SUBNETID

#Create the Redshift cluster
REDSHIFTID =`aws redshift create-cluster --cluster-identifier ndcdemo --node-type dc1.large \
    --master-username admin --master-user-password Password1 \
    --cluster-type single-node --db-name ndc --cluster-subnet-group-name $SUBNETGROUP`
    
#Create/alter a security group
REDSHIFTSECURITYGROUP='aws redshift create-cluster-security-group'...

# TODO - Pattern to add tags to resources
aws redshift create-tags --resources ami-<value> i-<value> --tags Key=show,Value=ndc

#Access the public S3 data bucket
#Use Matillion to load the data (pre-load some data)
# TODO


