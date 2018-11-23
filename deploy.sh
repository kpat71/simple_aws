# Export own account stacks
export AWS_PROFILE=temp
ENV="$1"

if [ "$1" = "prod" ]; then
    echo "Deploying $ENV environment"   
else
    ENV="test"
    echo "Deploying $ENV environment" 
fi
   
# VPC and subnets 
REGION="eu-west-1"
STACK_NAME="$ENV-VPC"
TEMPLATE="network.yaml"

if [ "$ENV" = "test" ]; then
   SUBNET="10"
   DNS_DOMAIN_NAME="$ENV.net"
elif [ "$ENV" = "prod" ]; then  
   SUBNET="11"
   DNS_DOMAIN_NAME="$ENV.net" 
else
   exit 
fi

aws cloudformation deploy \
    --region $REGION \
    --capabilities CAPABILITY_IAM \
    --stack-name $STACK_NAME \
    --template-file $TEMPLATE \
    --parameter-overrides \
        VpcSubnet="10."$SUBNET".0.0/16" \
        fe1="10."$SUBNET".1.0/20" \
        app1="10."$SUBNET".48.0/20" \
        be1="10."$SUBNET".96.0/20" \
        fe2="10."$SUBNET".16.0/20" \
        app2="10."$SUBNET".64.0/20" \
        be2="10."$SUBNET".112.0/20" \
        az1="$REGION"a \
        az2="$REGION"b \
        DnsDomainName="$DNS_DOMAIN_NAME" \
    --tags \
        Environment="$ENV"

# EIP
REGION="eu-west-1"
STACK_NAME="$ENV-EIP"
TEMPLATE="eip.yaml"

aws cloudformation deploy \
    --region $REGION \
    --capabilities CAPABILITY_IAM \
    --stack-name $STACK_NAME \
    --template-file $TEMPLATE \
    --parameter-overrides \
        EipName1=WebServer \
    --tags \
        Environment="$ENV"

# SG
REGION="eu-west-1"
STACK_NAME="$ENV-SG"
TEMPLATE="security_groups.yaml"

aws cloudformation deploy \
    --region $REGION \
    --capabilities CAPABILITY_IAM \
    --stack-name $STACK_NAME \
    --template-file $TEMPLATE \
    --parameter-overrides \
        VpcId="$ENV"-VPC-VPCID \
        VpcSubnet="$ENV"-VPC-feIdaz1 \
    --tags \
        Environment="$ENV"

# EC2
REGION="eu-west-1"
STACK_NAME="$ENV-EC2"
TEMPLATE="ec2.yaml"

aws cloudformation deploy \
    --region $REGION \
    --capabilities CAPABILITY_IAM \
    --stack-name $STACK_NAME \
    --template-file $TEMPLATE \
    --parameter-overrides \
        AssociatePublicIpAddress=false \
        ImageId=ami-0a5e707736615003c \
        InstanceType=t3.nano \
        KeyName=Default \
        SecurityGroup="$ENV"-SG-HttpsHttpSshAll \
        serverEIP="$ENV"-EIP-WebServer \
        SubnetId="$ENV"-VPC-feIdaz1 \
        TagEnvironment="$ENV" \
        VpcId="$ENV"-VPC-VPCID \
        AnsibleCommand="ansible-playbook -i inventories/"$ENV"/hosts site.yml" \
    --tags \
        Environment="$ENV"
