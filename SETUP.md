# WarVM — Free Cloud Setup (Google Cloud $300 Credit)

Google Cloud gives **$300 free credit** when you sign up — enough to run WarVM for **~3 months** at no cost.

---

## Step 1 — Create a free Google Cloud account

1. Go to **https://cloud.google.com/free**
2. Click **"Get started for free"**
3. Sign in with a Google account
4. Enter billing info (required for verification — you will NOT be charged unless you manually upgrade)
5. Your **$300 credit** is added automatically

---

## Step 2 — Create a project & enable APIs

1. Go to **https://console.cloud.google.com**
2. Click the project dropdown → **"New Project"** → name it `warvm` → **Create**
3. Copy your **Project ID** (e.g. `warvm-123456`) — you'll need it later
4. Enable the Compute Engine API:
   - Go to **APIs & Services → Library**
   - Search **"Compute Engine API"** → click **Enable**

---

## Step 3 — Install tools on your computer

### Install Terraform
```bash
# macOS
brew install terraform

# Windows (run in PowerShell as Admin)
winget install HashiCorp.Terraform

# Linux
sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

### Install Google Cloud CLI
```bash
# macOS
brew install --cask google-cloud-sdk

# Windows — download installer:
# https://cloud.google.com/sdk/docs/install#windows

# Linux
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
```

---

## Step 4 — Authenticate

```bash
gcloud auth application-default login
# A browser window opens — log in with the same Google account
```

---

## Step 5 — Deploy WarVM

```bash
git clone https://github.com/anaghnathwani/warvm.git
cd warvm/terraform

# Create your config file
cat > terraform.tfvars << EOF
project_id     = "YOUR_PROJECT_ID_HERE"   # ← paste your project ID
warvm_password = "WarThunder1!"           # ← change if you want
EOF

terraform init
terraform apply
# Type "yes" when prompted
# Takes ~5 minutes to provision
```

---

## Step 6 — Access your VM

After `terraform apply` finishes, you'll see:

```
Outputs:
  web_ui   = http://34.X.X.X/
  novnc_url = http://34.X.X.X/vm/
  rdp       = 34.X.X.X:3389
```

1. Open **`http://34.X.X.X/`** in your browser
2. Click **"Launch VM"**
3. Windows 11 first boot takes **~10 minutes**
4. After setup, Chrome + War Thunder install automatically
5. Log in to War Thunder and play!

---

## Cost breakdown

| Resource | Monthly cost (from $300 credit) |
|----------|----------------------------------|
| n2-standard-4 VM (4 vCPU, 16 GB) | ~$97/mo |
| 150 GB SSD | ~$15/mo |
| Static IP | ~$3/mo |
| **Total** | **~$115/mo → ~2.6 months free** |

> After your credit runs out, stop the VM via `terraform destroy` or the GCP console to avoid charges.

---

## Stopping / destroying

```bash
# Stop (preserves disk, stops billing for compute)
gcloud compute instances stop warvm-server --zone=us-central1-a --project=YOUR_PROJECT_ID

# Restart
gcloud compute instances start warvm-server --zone=us-central1-a --project=YOUR_PROJECT_ID

# Full teardown (deletes everything)
cd warvm/terraform
terraform destroy
```
