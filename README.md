# rewind-job

#### Prerequisite to deploy this app to AWS ECS Fargate Cluster
* Generate self signed SSL
* To generate self signed SSL run the following commands

```console 
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout privateKey.key -out certificate.crt
```

* Verify the keys 

```console
openssl rsa -in privateKey.key -check
openssl x509 -in certificate.crt -text -noout
```

* Convert the key and cert into .pem encoded file

```console
openssl rsa -in privateKey.key -text > private.pem
openssl x509 -inform PEM -in certificate.crt > public.pem
```

* Upload the keys to AWS IAM

```console
aws iam upload-server-certificate --server-certificate-name CSC --certificate-body file://public.pem --private-key file://private.pem
```


#### CI/CI is configured using github actions
* Push/Merge/PR to the master branch will trigger the build 
* The build will do the following
    - Build and deploy docker to docker hub
    - Use the docker image as the base for the fargate container
    - Run terraform scripts to deploy the ECS Cluster
* Both the above steps are configured using github actions see (rewind-job/.github/workflows/terraform-workflow.yml)
* If you are making changes to the image, update the following value in the terraform/vars.tf file

```console
variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "rajbarath/flask-app:v0.1"
}
```


### Terraform 
* VPC and subnets are separate for dev and prod

```console
prod = 10.100.0.0/16
dev = 10.1.0.0/16
```
* Terraform uses dev and prod workspaces, and it dynamically chooses dev/prod cidr and subnets based on the selected           workspace or it selects based on the prefix(dev/prod) if it uses the default workspace. see below

* The backend is configured with S3, tfstate files get saved there

* To deploy the infrastructure 

```console
# To initialize 
terraform init 

# Swith workspace to either dev/prod
terraform workspace select dev

# To check the changes
terraform plan

#To apply the changes
terraform apply -var="prefix=dev"
#or
terraform apply -var="prefix=prod"

```

* The above steps will create the following
1. VPC and subnets 
2. ECS Cluster
3. Autosclaing group for the ECS cluster
    - Scale up when the CPU => 85 for 120 seconds
    - Scale down when the CPU <= 10 for 120 seconds
4. Application loadbalancer with target group
    - it allows only access using https
5. ECS task execution role attachment
6. Cloudwatch - To capture the logs from the fargate 
7. Security group for ECS and ALB
    - ECS allows access only from ALB
    - ALB only https is open

* ECS cluster are region specific, we can maintain high availablity by spinning the cluser across multiple AZ's as well as regions
* Monitor and alert( via email) when the load reaches beyond a set threshold in cloudwatch alarms 
* It's highly scalable as we can add/remove fargate containers


* I have commented the code in alarms.tf as it' executing aws cli command to subscribe an email
  to the alert, however, in github actions I get the following error

```console
aws_sns_topic.ecs_cpu_usage: Provisioning with 'local-exec'...
aws_sns_topic.ecs_cpu_usage (local-exec): Executing: ["/bin/sh" "-c" "aws sns subscribe --topic-arn arn:aws:sns:ca-central-1:xxxxxxxxx:ecs_cpu_topic --protocol email --notification-endpoint someemail@some.org"]
aws_sns_topic.ecs_cpu_usage (local-exec): /bin/sh: aws: not found

```
* I'd need more time to fix the above issue




