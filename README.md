# terraform-hcloud-linux-desktop

Terraform module for provisioning a Linux desktop server on Hetzner Cloud.

**Status:** Production-ready. Tested with Hetzner Cloud, Terraform 1.x, hetznercloud/hcloud provider >= 1.47.

---

## Table of Contents

- [What Problem Does This Solve?](#what-problem-does-this-solve)
- [Disclaimer](#disclaimer)
- [Tested On](#tested-on)
- [Usage](#usage)
- [Requirements](#requirements)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Architecture](#architecture)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## What Problem Does This Solve?

Provision a Linux desktop server on Hetzner Cloud in a single `terraform apply` — no manual cloud console work. Designed to work with the [linux-desktop-seed](https://github.com/DarojaAI/linux-desktop-seed) deployment scripts which handle OS setup, RDP, and development tools after the VM is created.

**Typical workflow:**

```
terraform apply (this module) → creates VM with public IP
        ↓
linux-desktop-seed/deploy-desktop.sh → installs desktop environment
        ↓
Connect via RDP → full Linux desktop
```

---

## Disclaimer

**Use at your own risk.** This module provisions real infrastructure that costs money. Review variable values before applying.

- No guarantees of stability, security, or fitness for any particular purpose
- Always `terraform plan` before `terraform apply`
- The [MIT license](LICENSE) applies: this software is provided "as is", without warranty of any kind

---

## Tested On

Validated against:

| Component | Version |
|---|---|
| Terraform | 1.7+ |
| Provider | hetznercloud/hcloud >= 1.47 |
| Location | fsn1, nbg1, hel1 |
| Image | ubuntu-22.04, ubuntu-24.04 |
| Server types | cpx21, cpx41, cax41 |

---

## Usage

```hcl
module "linux_desktop" {
  source  = "DarojaAI/linux-desktop/hcloud"
  version = "1.0.0"

  hcloud_token = var.hcloud_token
  server_name  = "my-desktop"
  location     = "fsn1"
  server_type  = "cpx41"
  image        = "ubuntu-22.04"

  hetzner_ssh_key_name = "my-ssh-key"

  labels = {
    project    = "linux-desktop"
    managed_by = "terraform"
  }
}

output "connection_info" {
  value = module.linux_desktop.connection_info
}
```

**After applying**, SSH into the VM and run [linux-desktop-seed](https://github.com/DarojaAI/linux-desktop-seed) deployment scripts to set up the desktop environment.

---

## Requirements

| Resource | Version |
|---|---|
| Terraform | >= 1.0 |
| hetznercloud/hcloud provider | >= 1.47 |

Provider configuration:
```hcl
provider "hcloud" {
  token = var.hcloud_token
}
```

---

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| `hcloud_token` | Hetzner API token. Create one at [console.hetzner.cloud](https://console.hetzner.cloud/) under Access → API Tokens | `string` | — | Yes |
| `server_name` | Server name. Must be unique in your Hetzner project. Used as the hostname and visible in the Hetzner console | `string` | — | Yes |
| `server_type` | Hetzner server type. See [hetzner.com/cloud/pricing](https://www.hetzner.com/cloud/pricing) | `string` | `"cpx41"` | No |
| `location` | Datacenter location. Options: `fsn1`, `nbg1`, `hel1`, `ash` | `string` | `"fsn1"` | No |
| `image` | OS image name or ID. Use slug (e.g., `ubuntu-22.04`) or numeric ID | `string` | `"ubuntu-22.04"` | No |
| `ssh_keys` | List of SSH key names or IDs to attach. Leave empty if using `hetzner_ssh_key_name` | `list(string)` | `[]` | No |
| `hetzner_ssh_key_name` | Name of a single SSH key in Hetzner. Alternative to `ssh_keys` for simpler setups | `string` | `""` | No |
| `ssh_public_key` | SSH public key content to inject at boot for passwordless access | `string` | `""` | No |
| `labels` | Key-value pairs to apply as labels to the server. Useful for organization and cost tracking | `map(string)` | `{}` | No |

### Server Type Reference

| Type | vCPUs | RAM | Storage | Max Price |
|---|---|---|---|---|
| `cx22` | 2 | 4 GB | 40 GB | ~$4.89/mo |
| `cx32` | 2 | 8 GB | 80 GB | ~$6.89/mo |
| `cpx31` | 3 | 6 GB | 80 GB | ~$8.89/mo |
| `cpx41` | 4 | 8 GB | 160 GB | ~$12.59/mo |
| `cpx51` | 8 | 16 GB | 240 GB | ~$21.49/mo |
| `cax41` | 4 | 16 GB | 80 GB | ~$18.89/mo |

*Prices are approximate. Check [hetzner.com/cloud/pricing](https://www.hetzner.com/cloud/pricing) for current rates.*

---

## Outputs

| Name | Description |
|---|---|
| `server_id` | Hetzner server ID (useful for import) |
| `server_name` | Server name as specified |
| `ipv4_address` | Public IPv4 address. Use this to connect via SSH or RDP |
| `ipv6_address` | Public IPv6 address |
| `connection_info` | Ready-to-use SSH command. Example: `ssh -o StrictHostKeyChecking=no root@123.456.78.90` |
| `server_status` | Current server status: `running`, `off`, `creating`, `deleting` |

---

## Architecture

### What this module creates

```
hcloud_server.main (VM)
├── Public IPv4 (assigned by Hetzner)
├── Public IPv6 (assigned by Hetzner)
└── Labels (from var.labels)
```

### What this module does NOT create

This module only provisions the VM. It does **not** include:
- Firewall rules (create separately with `hcloud_firewall` resource)
- Networks or subnets (Hetzner VMs are on a private network by default)
- DNS records (manage separately)
- SSH key generation (use existing keys or `tls_private_key`)
- Post-provisioning setup (use [linux-desktop-seed](https://github.com/DarojaAI/linux-desktop-seed) for that)

### Recommended follow-up

After `terraform apply`, run the linux-desktop-seed deployment scripts to install the desktop environment:

```bash
ssh root@<ipv4_address>
git clone https://github.com/DarojaAI/linux-desktop-seed.git
cd linux-desktop-seed
sudo bash deploy-desktop.sh
```

---

## Security Considerations

### API Token
`hcloud_token` is marked as `sensitive = true` in Terraform state. Protect your state file:
- Use remote backend with encryption (S3, Terraform Cloud)
- Never commit `.tfstate` files to version control

### SSH Access
- Prefer `hetzner_ssh_key_name` or `ssh_keys` over `ssh_public_key` where possible
- If using `ssh_public_key`, ensure the private key is stored securely

### Firewall
This module does not create firewall rules. After provisioning, ensure port 3389 is open for RDP if you plan to use the desktop:

```hcl
resource "hcloud_firewall" "desktop" {
  name = "desktop-fw"

  rule {
    direction = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction = "in"
    protocol   = "tcp"
    port       = "3389"
    source_ips  = ["0.0.0.0/0"]  # restrict to your IP in production
  }

  apply_to {
    server = hcloud_server.main.id
  }
}
```

---

## Troubleshooting

### Server stays in `creating` state

Wait 1-2 minutes. Hetzner provisioning can take time for custom images or under high load.

### `Error: Invalid SSH key`

Ensure the SSH key name in `hetzner_ssh_key_name` exactly matches a key in your Hetzner project. SSH keys are project-scoped, not account-scoped.

### `Error: Image not found`

Use the exact image slug from Hetzner's available images. Check [docs.hetzner.cloud](https://docs.hetzner.cloud/servers#available-images) for the current list.

### `terraform apply` fails with 401

Your `hcloud_token` is invalid or expired. Generate a new one at [console.hetzner.cloud](https://console.hetzner.cloud/) → Access → API Tokens.

### How to import an existing server

If you have a server already running and want to manage it with Terraform:

```bash
terraform import hcloud_server.main <SERVER_ID>
```

---

## Contributing

When updating this module:

- Run `terraform fmt` and `terraform validate` before committing
- Update inputs/outputs tables in this README if variables change
- Test against a real Hetzner project (use a throwaway project for testing)
- State is consumer-managed — do not include `backend` blocks in this module

---

## License

MIT — see [LICENSE](LICENSE) for the full text.