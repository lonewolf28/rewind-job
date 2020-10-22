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
* Push/Merge to the master branch will trigger the build 
* The build will build docker container with the app and upload it to docker hub
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
* Terraform uses dev and prod workspaces, and it dynamically chooses dev/prod cidr based on the selected workspace
* The backend is configure with S3, tfstate files get saved there

* To deploy the infrastructure 

```console
# To initialize 
terraform init 

# Swith workspace to either dev/prod
terraform workspace select dev

# To check the changes
terraform plan

#To apply he changes, if you have any variables specific to an environment add it to either dev/prod tfvars
terraform apply -var-file=dev.tfvars
```

* The above steps will create the following
1. VPC and subnets 
2. ECS Cluster
3. Autosclaing group for the ECS cluster
    - Scale up when the CPU => 85 for 120 seconds
    - Scale down when the CPU <= 10 for 120 seconds
4. Application loadbalancer with target group
5. ECS task execution role attachment
6. Cloudwatch - To capture the logs from the fargate 
7. 



