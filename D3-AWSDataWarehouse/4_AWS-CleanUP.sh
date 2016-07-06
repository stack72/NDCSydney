
#!/bin/bash

#-----Removes all demo resources-------------------------------------

set -e

#TODO - Determine and update 'destruction order' of objects
# IAM user, Networking Objects (VPC, etc..), Redshift, EC2 instances, others?

# Delete IAM User and Role w/ permissions on S3, EC2, Redshift
warehouseUser = 'aws iam delete-user ....'
echo warehouseUser $warehouseUser deleted

#Delete a VPC
vpcId=`aws ec2 create-vpc --cidr-block 10.0.0.0/16 | jq .Vpc.VpcId -r`
echo vpc $vpcId deleted

#Delete a subnet
subnetid=`aws ec2 create-subnet --vpc-id $vpcId --cidr-block 10.0.0.0/16| jq .Subnet.SubnetId -r`
echo subnet $subnetid deleted

#Delete an Internet gateway
gatewayid=`aws ec2 create-internet-gateway| jq .InternetGateway.InternetGatewayId -r`
echo gateway $gatewayid deleted

#Delete internet gateway
aws ec2 attach-internet-gateway --internet-gateway-id  $gatewayid --vpc-id  $vpcId

#Delete default route to route table.
routetableId=`aws ec2 describe-route-tables | jq .RouteTables[0].RouteTableId -r`
echo route table $routetableId found
aws ec2 create-route --route-table-id $routetableId --destination-cidr-block 0.0.0.0/0 --gateway-id $gatewayid

#Delete redshift rule into the security group
securityGroupId=`aws ec2 describe-security-groups --filters Name=vpc-id,Values=$vpcId | jq .SecurityGroups[0].GroupId -r`
aws ec2 authorize-security-group-ingress --group-id $securityGroupId  --protocol tcp --port 5439 --cidr 10.0.0.0/16

#Delete public S3 data bucket
# TODO



##END SCRIPT