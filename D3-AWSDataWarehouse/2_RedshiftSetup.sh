
#!/bin/bash

set -e

#-----Sets up Redshift on AWS EC2-------------------------------------

REGION = '< my AWS region >' # for Australia use 'ap-southeast-2'
MYKEYPAIR = '< my keypair >'

VPCID=`aws ec2 describe-vpc --region $REGION`
SUBNETID=`aws ec2 describe-subnet --region $REGION`
ROUTETABLEID=`aws ec2 describe-route-tables --region $REGION`
GATEWAYID=`aws ec2 create-internet-gateway --region $REGION`

aws ec2 create-route --route-table-id $ROUTETABLEID --destination-cidr-block 0.0.0.0/0 --gateway-id $GATEWAYID
SECURITYGROUPIDRS=`aws ec2 describe-security-groups --filters Name=vpc-id,Values=$VPCID`
aws ec2 authorize-security-group-ingress --group-id $SECURITYGROUPIDRS  --protocol tcp --port 5439 --cidr 10.0.0.0/16

SUBNETGROUP = aws redshift create-cluster-subnet-group --cluster-subnet-group-name "ndcdemo" \
    --description "ndcdmo" --subnet-ids $SUBNETID

REDSHIFTSECURITYGROUP='aws redshift create-cluster-security-group'...

REDSHIFTID =`aws redshift create-cluster --cluster-identifier ndcdemo --node-type dc1.large \
    --master-username admin --master-user-password Password1 \
    --cluster-type single-node --db-name ndc --cluster-subnet-group-name $SUBNETGROUP`
    




