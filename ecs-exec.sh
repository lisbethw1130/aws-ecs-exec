#!/usr/bin/env sh

set -u

# If you have multiple AWS CLI binaries, v1 and v2 for instance, you can choose which AWS CLI binary to use by setting the AWS_CLI_BIN env var.
# e.g. AWS_CLI_BIN=aws-v1 ./check-ecs-exec.sh YOUR_ECS_CLUSTER_NAME YOUR_ECS_TASK_ID
AWS_CLI_BIN=${AWS_CLI_BIN:-aws}

# Force AWS CLI output format to json to use jq to parse its output
export AWS_DEFAULT_OUTPUT=text

n=1
while [ $# -gt 0 ]
do
  case $1 in
    -*) break;;
    *) eval "arg_$n=\$1"; n=$(( $n + 1 )) ;;
  esac
  shift
done

if [ -z "$arg_1" ] || [ -z "$arg_2" ]
then
   echo "Some or all of the parameters are empty";
fi

STOP_ON_EXIT='false'
while getopts ":r" arg; do
  case $arg in
    r)
      STOP_ON_EXIT='true'
      ;;
    ?)
      echo "Invalid option: -${OPTARG}."
      exit 1;
      ;;
  esac
done

taskArn=$(aws ecs run-task \
	--cluster ${arg_1} \
	--task-definition ${arg_2} \
	--enable-execute-command \
	--query "tasks[0].taskArn" --output text)

time=1
while [[ $(aws ecs describe-tasks --cluster ${arg_1} --tasks ${taskArn} --query "tasks[0].containers[0].managedAgents[0].lastStatus" --output text) == "PENDING" ]]
do
	echo "start task with ARN: ${taskArn}"
	printf "Waiting for task and agent start up...${time}s\r"
	((time++))
	sleep 1
done

aws ecs execute-command \
--cluster ${arg_1} \
--task ${taskArn} \
--command /bin/sh \
--interactive

if [[ ${STOP_ON_EXIT} == true ]];then

	echo 'STOPPING task'
	aws ecs stop-task \
	--cluster ${arg_1} \
	--task ${taskArn} \
	--output text
fi
