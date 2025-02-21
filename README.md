# Terraform AWS Infrastructure  

This repository contains Terraform configuration files to provision AWS resources.  


##  Steps

### 1️⃣ Configure AWS credentials  
```bash
aws configure

or

export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"

or

add the keys to your script (It is not advisable)
```

### 2️⃣ Initialize Terraform
```bash
terraform init
```
3️⃣ Preview changes
```bash
terraform plan
```
4️⃣ Apply configuration
```bash
terraform apply -auto-approve
```
5️⃣ Destroy resources (if needed)
```bash
terraform destroy -auto-approve
```

🚀 Happy Terraforming! 🌍🔧

