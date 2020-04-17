#!/usr/bin/env bash
#
# Run script for tutorial in order to make sure nothing gets screwed up.

set +x

aws cloudformation create-stack --stack-name rexray-demo \
--capabilities CAPABILITY_NAMED_IAM \
--template-body file://rexray-demo.yaml \
--parameters ParameterKey=KeyName,ParameterValue=admin

bash get-outputs.sh rexray-demo us-east-1 && source <(bash get-outputs.sh rexray-demo us-east-1)

bash create-postgresql-taskdef-json.sh

aws ec2 create-volume --size 1 --volume-type gp2 \
--availability-zone $AvailabilityZone \
--tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=rexray-vol}]'

export TaskDefinitionArn=$(aws ecs register-task-definition --cli-input-json 'file://postgresql-taskdef.json' | jq -r .taskDefinition.taskDefinitionArn)

bash create-postgresql-svcdef-json.sh

export SvcDefinitionArn=$(aws ecs create-service --cli-input-json file://postgresql-svcdef.json | jq -r .service.serviceArn)
