### Since we have done environmental seperation and tagging the correct way to run/init becomes
```bash
terraform init -backend-config="backends/dev.hcl"
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
terraform destroy -var-file="environments/dev.tfvars"
```
### or depending on the enviroment
```bash
terraform init -backend-config="backends/prod.hcl"
terraform plan -var-file="environments/prod.tfvars"
terraform apply -var-file="environments/prod.tfvars"
terraform destroy -var-file="environments/prod.tfvars"
```

### For kubeconfig
```bash
aws eks update-kubeconfig --region <REGION_CODE> --name <CLUSTER_NAME>
```

## To tunnel to your EKS
```bash
# kubectl port-forward -n "${NAMESPACE}" svc/${SERVICE} ${LOCAL_PORT}:${REMOTE_PORT}
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## Service Type Load Balancer to connect to eks
```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```
After a short wait, your cloud provider will assign an external IP address to the service. You can retrieve this IP with:
```bash
kubectl get svc argocd-server -n argocd -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

## To get password 
```bash
argocd admin initial-password -n argocd
```

## Apply root app to cluster
```bash
kubectl apply -f "gitops/app of apps/root.yaml"
```

## For AWS ALB vpcID

We know that ArgoCD manages the app deployments but some controllers like LBC need infrastructure values like VPC ID that only exist after Terraform runs. I solved this by having Terraform render the ArgoCD Application manifests from templates, so the GitOps repo always has the correct values after every apply.