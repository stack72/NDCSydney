
#!/bin/bash

set -e

#-----Removes all demo resources-------------------------------------

REGION = 'ap-southeast-2'

# TODO - Determine and update 'destruction order' of objects

WAREHOUSEUSER = 'aws iam delete-user ....'
WAREHOUSEROLE = 'aws iam delete-role ... '
WAREHOUSEPOLICY= 'aws iam delete-policy ....'

# Delete a VPC
vpcId=`aws ec2 delete-vpc --cidr-block 10.0.0.0/16 | jq .Vpc.VpcId -r`
echo vpc $vpcId deleted

# Delete a subnet
subnetid=`aws ec2 delete-subnet --vpc-id $vpcId --cidr-block 10.0.0.0/16| jq .Subnet.SubnetId -r`
echo subnet $subnetid deleted

# Detach internet gateway 
aws ec2 detach-internet-gateway --internet-gateway-id  $gatewayid --vpc-id  $vpcId

# Delete an Internet gateway
gatewayid=`aws ec2 delete-internet-gateway| jq .InternetGateway.InternetGatewayId -r`
echo gateway $gatewayid deleted

# Delete default route to route table.
routetableId=`aws ec2 describe-route-tables | jq .RouteTables[0].RouteTableId -r`
echo route table $routetableId found
aws ec2 delete-route --route-table-id $routetableId --destination-cidr-block 0.0.0.0/0 --gateway-id $gatewayid

# Delete redshift rule into the security group - TO:'unauthorize'
securityGroupId=`aws ec2 describe-security-groups --filters Name=vpc-id,Values=$vpcId | jq .SecurityGroups[0].GroupId -r`
aws ec2 authorize-security-group-ingress --group-id $securityGroupId  --protocol tcp --port 5439 --cidr 10.0.0.0/16

# Find EC2 tagged instances and delete them (Matillion, YellowFin)
# TODO - Pattern to add tags to resources
aws ec2 describe-instances --resources ami-<value> i-<value> --tags Key=show,Value=ndc
aws ec2 terminate-instances ....

# Find Redshift cluster tagged instances and delete them
# TODO - Pattern to add tags to resources
redshiftCluster='aws redshift describe-instances --resources ami-<value> i-<value> --tags Key=show,Value=ndc'
aws redshift delete-cluster ....
echo redshiftCluster $redshiftCluster deleted

# Delete non-empty public S3 data bucket
demoBusket='aws s3 rb s3://<bucketName> <tag>.... --force'
echo s3 $demoBucket deleted

##END SCRIPT