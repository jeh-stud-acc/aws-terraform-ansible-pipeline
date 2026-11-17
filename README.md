# Automated AWS Server Pipeline (Terraform · Ansible · InSpec)

A CI/CD pipeline that builds a Linux web server on AWS, configures it, checks it against compliance rules, and tears it down when it's no longer needed, all from code. I built it for **IT 351** at Marymount University in Fall 2026. It originally ran on GitLab CI using the course's GitLab runner and GitLab's CI/CD pipeline tool.

## What it does

Instead of clicking through the AWS console, every step is written down as code and run by the pipeline:

| Stage | Tool | What happens |
| --- | --- | --- |
| 1. Validate | Terraform | Checks the infrastructure code for errors |
| 2. Plan | Terraform | Shows exactly what will be created and saves that plan |
| 3. Apply *(manual approval)* | Terraform | Creates the server, its storage and its firewall rules on AWS, then hands the server's IP address to the next stage |
| 4. Configure | Ansible | Logs into the new server and installs and starts the Apache web server, publishes a web page, and installs the nano text editor |
| 5. Continuous Compliance | Chef InSpec | Checks the live AWS environment: the server exists, is running, uses the approved Amazon Linux image, and carries the required tag |
| 6. Destroy *(manual approval)* | Terraform | Deletes everything so nothing keeps running and costing money |

Apply and Destroy only run when a person approves them, so nothing is created or deleted by accident.

## What gets built

- **One EC2 server** (`t3.micro`, Amazon Linux) with a 10 GB root disk and a second 10 GB data disk
- **A security group (firewall)** that allows SSH (port 22) only from the pipeline runner's own security group, not the whole internet, and allows all outbound traffic
- **Remote Terraform state** kept in an S3 bucket, so the pipeline always knows what it has already built

## Files

| File | Purpose |
| --- | --- |
| `provider.tf` | AWS region (`us-east-1`) and the S3 state backend |
| `main.tf` | The server, disks, security group and firewall rules |
| `playbook.yml` | Ansible steps that configure the server |
| `index.html`, `my-project.txt` | Files Ansible copies onto the server |
| `lab-7-profile/` | InSpec compliance checks |
| `.gitlab-ci.yml` | The pipeline that runs every stage in order |

## Security notes

- **No credentials are stored in this repository.** AWS access comes from the CI runner's environment, and the SSH key Ansible uses is supplied as a GitLab CI/CD variable of type *File* (`SSH_PRIVATE_KEY`).
- `.gitignore` blocks private keys, Terraform state files and generated plans from ever being committed.
- SSH access to the server is limited to the runner's security group, not open to `0.0.0.0/0`.

## Running it yourself

You need an AWS account, an S3 bucket for Terraform state, an EC2 key pair, and a GitLab runner with AWS access.

1. Update the bucket name in `.gitlab-ci.yml`, the key pair name in `main.tf`, the runner security group ID in `main.tf`, and the runner tag (`it-351-runner`) to match your environment.
2. In GitLab, add a CI/CD variable named `SSH_PRIVATE_KEY`, type **File**, containing your EC2 private key.
3. Push to GitLab, then approve the **tf-apply** job when ready. Approve **tf-destroy** when finished.
