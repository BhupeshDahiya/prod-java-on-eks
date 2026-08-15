### Since we have done environmental seperation and tagging the correct way to run/init becomes
```code
terraform init -backend-config="backends/dev.hcl"
```
### or depending on the enviroment
```code
terraform init -backend-config="backends/prod.hcl"
```