# Kubernetes kubeadm Ansible Playbook

This project deploys a kubeadm-based Kubernetes cluster on Ubuntu hosts with:

- the current upstream Kubernetes stable release resolved from `https://dl.k8s.io/release/stable.txt`
- the latest `containerd.io` package from Docker's official Ubuntu repository
- the latest Calico release tag resolved from the `projectcalico/calico` GitHub releases API

## Files

- `inventory/hosts.ini`: host file where you enter server IPs, SSH user, SSH password, and sudo password
- `group_vars/all.yml`: shared cluster settings
- `playbook.yml`: cluster deployment playbook
- `uninstall.yml`: cluster teardown playbook
- `cns.sh`: wrapper script for common install, uninstall, and help commands

## Requirements

- Ansible installed on the control machine
- `sshpass` installed on the control machine if you use `ansible_ssh_pass`
- Ubuntu hosts reachable over SSH
- SSH user with sudo privileges

## Usage

1. Edit `inventory/hosts.ini` and replace the example IPs and passwords.
2. Optionally edit `group_vars/all.yml` if you want a different pod CIDR or service CIDR.
3. Use the wrapper script:

```bash
./cns.sh install
```

To remove everything installed by the deployment playbook, run:

```bash
./cns.sh uninstall
```

To see the available wrapper commands, run:

```bash
./cns.sh help
```

The wrapper calls `ansible-playbook playbook.yml` for installs and `ansible-playbook uninstall.yml` for teardown.

## Notes

- The inventory is set up for one control plane node plus optional worker nodes.
- If you want a stable virtual IP or load balancer for the API server, set `control_plane_endpoint` in `group_vars/all.yml`.
- Kubernetes packages are placed on hold after installation, which is the standard kubeadm baseline.
