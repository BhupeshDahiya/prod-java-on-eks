### Since we have done environmental seperation and tagging the correct way to run/init becomes
```code
terraform init -backend-config="backends/dev.hcl"
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
terraform destroy -var-file="environments/dev.tfvars"
```
### or depending on the enviroment
```code
terraform init -backend-config="backends/prod.hcl"
terraform plan -var-file="environments/prod.tfvars"
terraform apply -var-file="environments/prod.tfvars"
terraform destroy -var-file="environments/prod.tfvars"
```