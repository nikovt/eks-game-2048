# DevOps Challenge

## Exercise
* EKS (Elastic Kubernetes Service)
  * Using node groups
* Convert the k8s yaml files to a helm chart
* Deploy helm chart to the EKS cluster
* Expose the application deployed in EKS via an ALB (Application Load Balancer)
    * We recommend using [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/)

### Terraform Requirements:
* Terraform code should be formatted using `terraform fmt`
* Terraform version must be 0.15.3 or higher
* State should be stored in s3 - ensure there is some way for to easily create and destroy the s3 bucket and dynamodb table

### Application
The application is the 2048 and application.yaml file needs to be converted into a helm chart (charts/ folder)
Please consider the following:
* Helm chart should be written in Helm 3
* What variables should be exposed out
* Consider namespacing and how you handle this


## Deploying

### Prerequisites
* Installed and Configured AWS Cli version >=2
```shell
$ aws configure
AWS Access Key ID [None]: <YOUR_AWS_ACCESS_KEY_ID>
AWS Secret Access Key [None]: <YOUR_AWS_SECRET_ACCESS_KEY>
Default region name [None]: eu-west-2
Default output format [None]: json
```
* Installed Terraform >=0.15
* Installed aws-iam-authenticator 
* Installed jq
* Installed wget (required for the eks module)
* User provisioning the cluster have IAM credentials with Administrator permissions 

### Provisioning Steps:
* Create Dynamodb lock table and Terraform S3 state store bucket. Run:
```sh
./init_tf_setup.sh cba47ab8-e741-11eb-ba80-0242ac130009 e1fa885c-e741-11eb-ba80-0242ac130007
```
> Note: In the unlikely event of already existing s3 bucket with that name, please use a different bucket name
* Provision EKS cluster stack with Terraform. Run:
```sh
terraform init && terraform apply -auto-approve
```
> Note: In some rare cases there are race conditions provisioning the whole stack. Make sure to run that again if that's the case
* Retrieve the generated by the AWS Load Balancer Controller ALB's DNS name and use that to render the game in the browser

## Cleanup 
* Remove Terraform stack: Run:
```sh
terraform destroy -auto-approve
```
> Note: In some cases that may need running more than one, or remove manually items from the tf state that tf didn't removed correctly despite the added dependencies. For example:
```sh
terraform state rm kubernetes_namespace.game_2048
```
* Remove Dynamodb lock table and Terraform S3 state store bucket. Run
```sh
./clean_up.sh cba47ab8-e741-11eb-ba80-0242ac130009 e1fa885c-e741-11eb-ba80-0242ac130007
```