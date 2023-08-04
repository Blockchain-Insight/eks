AWS credentials configuration
```bash
  export AWS_ACCESS_KEY_ID="XXXXXX"
```
```bash
  export AWS_SECRET_ACCESS_KEY="XXXXX"
```
```bash
aws configure --profile test
AWS Access Key ID [None]: xxxxx
AWS Secret Access Key [None]: xxxxx
Default region name [None]: eu-central-1
Default output format [None]: json
```




Clone the eks repository: https://github.com/Blockchain-Insight/eks
```bash
git clone git@github.com:Blockchain-Insight/eks.git
```
Change to cloned eks repository.
```bash
cd eks
```
Edit the **variables.tfvars** file for required inputs.
```bash
vim variables.tfvars
```
Shown below are dummy values. Enter the required inputs and save the variables.tfvars.
```bash
# AWS region
region        = "eu-central-1"
# Name of eks cluster
cluster_name  = "demo"
# Instance type for eks cluster
instance_type = ["abc.large"]
# AWS account id
account_id    = "12345687"
```
Terraform initialize
```bash
terraform init
```
You should see similar output once initialization is successful.
```bash
Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```
Terraform plan
```bash
terraform plan -var-file variables.tfvars
```
The output will list the resources that will be planed for creation. The end of the output should be something similar to
```bash
Plan: 74 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + cluster_oidc_issuer_url = (known after apply)
```
Terraform apply
```bash
terraform apply -var-file variables.tfvars
```
The output will be something similar to following and ask you to enter a **yes** if you want to create the resources in AWS
```bash
Plan: 74 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + cluster_oidc_issuer_url = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: 
```
Enter a **yes** on your screen. Terraform will start applying and show the status log on your screen. It will take upto 30 Minutes for the apply to complete

Connecting to cluster
```bash
aws eks update-kubeconfig --name hypersign
```
Output will be
```bash
Updated context arn:aws:eks:eu-central-1:xxxxxxxx:cluster/hypersign in /Users/xxxx/.kube/config
```
```bash
kubectl get ns
NAME              STATUS   AGE
default           Active   45m
kube-node-lease   Active   45m
kube-public       Active   45m
kube-system       Active   45m
```

```bash
kubectl get all -n default
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   x.x.x.x      <none>        443/TCP   46m

```

```bash
kubectl get all -n kube-system
NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR              AGE
daemonset.apps/aws-node               3         3         3       3            3           <none>                     46m
daemonset.apps/ebs-csi-node           3         3         3       3            3           kubernetes.io/os=linux     10m
daemonset.apps/ebs-csi-node-windows   0         0         0       0            0           kubernetes.io/os=windows   10m
daemonset.apps/kube-proxy             3         3         3       3            3           <none>                     46m

 NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/coredns              2/2     2            0           51m
deployment.apps/ebs-csi-controller   2/2     2            0           14m

```

```bash
% kubectl get nodes
NAME                                           STATUS   ROLES    AGE   VERSION
ip-10-0-24-233.eu-central-1.compute.internal   Ready    <none>   40m   v1.24.11-eks-a59e1f0
ip-10-0-24-36.eu-central-1.compute.internal    Ready    <none>   40m   v1.24.11-eks-a59e1f0
ip-10-0-39-50.eu-central-1.compute.internal    Ready    <none>   40m   v1.24.11-eks-a59e1f0

```


```bash
terraform destroy --var-file=variables.tfvars
```

```bash
Plan: 0 to add, 0 to change, 74 to destroy.

Changes to Outputs:
  - cluster_oidc_issuer_url = "https://oidc.eks.eu-central-1.amazonaws.com/id/xxxxxx" -> null

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value:

```


  
  
