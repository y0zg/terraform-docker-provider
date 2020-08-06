Terrafrom version

```
terraform {
  required_version = "> 0.12.0"
}
```

Dockerfile is located in root app code dir

Building and pushing docker image to Docker Hub repository
```
terraform init
terrafrom plan
terraform apply -auto-approve
terraform destroy -auto-approve
```