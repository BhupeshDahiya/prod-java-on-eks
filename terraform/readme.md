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

## Apply root app to cluster
```bash
kubectl apply -f "gitops/app of apps/root.yaml"
```
## To access your argoCD on EKS you have 2 ways

# To tunnel to your EKS
```bash
# kubectl port-forward -n "${NAMESPACE}" svc/${SERVICE} ${LOCAL_PORT}:${REMOTE_PORT}
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

# Service Type Load Balancer to connect to eks
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

## For AWS ALB vpcID

We know that ArgoCD manages the app deployments but some controllers like LBC need infrastructure values like VPC ID that only exist after Terraform runs. I solved this by having Terraform render the ArgoCD Application manifests from templates, so the GitOps repo always has the correct values after every apply.

## Destory order
# 1. Delete app namespaces to remove LBC-created resources (ALB, SGs, target groups)
```bash
kubectl delete namespace java-demo-app
kubectl delete namespace ingress-nginx
kubectl delete namespace monitoring
```
# 2. Wait for namespaces to fully terminate and AWS resources to be cleaned up
```bash
kubectl get namespaces
```
# 3. Delete ArgoCD to stop it from recreating anything
```bash
kubectl delete namespace argocd --force
```
# 4. Verify no load balancers or target groups remain
```bash
aws elbv2 describe-load-balancers --query 'LoadBalancers[*].LoadBalancerArn' --output table
aws elbv2 describe-target-groups --query 'TargetGroups[*].TargetGroupArn' --output table
```
# 5. If anything remains, delete manually in console then proceed
# EC2 → Load Balancers → delete
# EC2 → Target Groups → delete
# EC2 → Security Groups → delete any k8s-* ones

# 6. Terraform destroy
```bash
terraform destroy -var-file="environments/dev.tfvars"
```