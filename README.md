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
