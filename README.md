# terraform-hcloud-linux-desktop

Terraform module for provisioning a Linux desktop server on Hetzner Cloud.

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
}
```

## Requirements

| Resource | Description |
|---|---|
| Terraform | >= 1.0 |
| Provider | hetznercloud/hcloud >= 1.47 |

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| `hcloud_token` | Hetzner API token | `string` | — | Yes |
| `server_name` | Server name (must be unique in project) | `string` | — | Yes |
| `server_type` | Hetzner server type | `string` | `cpx41` | No |
| `location` | Datacenter location | `string` | `fsn1` | No |
| `image` | OS image | `string` | `ubuntu-22.04` | No |
| `ssh_keys` | List of SSH key names/IDs | `list(string)` | `[]` | No |
| `hetzner_ssh_key_name` | Single SSH key name (alternative to `ssh_keys`) | `string` | `""` | No |
| `labels` | Labels to apply to server | `map(string)` | `{}` | No |

## Outputs

| Name | Description |
|---|---|
| `server_id` | Hetzner server ID |
| `server_name` | Server name |
| `ipv4_address` | Public IPv4 address |
| `ipv6_address` | Public IPv6 address |
| `connection_info` | SSH command to connect |
| `server_status` | Current server status |

## License

MIT