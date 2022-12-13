# aws-ecs-exec

Inspired by [Amazon ECS Exec](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-exec.html)

You can put this shell in $PATH

```
$ chmod +x ecs-exec.sh
$ ./ecs-exec.sh <cluster_name> <task-defination>
```

You can add `-r` if want to delete task after logout

PRs are very welcome
