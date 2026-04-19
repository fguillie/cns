# Kubernetes kubeadm Ansible Playbook

This project deploys a kubeadm-based Kubernetes cluster on Ubuntu hosts with pinned component versions selected from a `cns_versions/cns-v*.txt` snapshot.

## Version Matrix

| Component | `cns_versions/cns-v1.34.6.txt` | `cns_versions/cns-v1.35.3.txt` |
| --- | --- | --- |
| kubeadm | `v1.34.6` | `v1.35.3` |
| Kubernetes | `v1.34.6` | `v1.35.3` |
| containerd | `v2.2.3` | `v2.2.3` |
| Calico | `v3.31.4` | `v3.31.4` |
| Helm | `v4.1.4` | `v4.1.4` |
| GPU Operator | `v26.3.1` | `v26.3.1` |

## Files

- `inventory/hosts.ini`: host file where you enter server IPs, SSH user, SSH password, and sudo password
- `group_vars/all.yml`: shared cluster settings
- `cns_versions/`: checked-in CNS component version snapshots
- `playbook.yml`: full deployment entry point that runs `kubernetes.yml` and then `gpu-operator.yml`
- `kubernetes.yml`: Kubernetes, containerd, kubeadm bootstrap, Calico, and worker join playbook
- `gpu-operator.yml`: Helm and NVIDIA GPU Operator playbook
- `tasks/parse_snapshot.yml`: shared CNS snapshot parsing tasks used by both install playbooks
- `uninstall.yml`: full teardown entry point that runs `uninstall-gpu-operator.yml` and then `uninstall-kubernetes.yml`
- `uninstall-gpu-operator.yml`: NVIDIA GPU Operator teardown playbook
- `uninstall-kubernetes.yml`: Calico, Kubernetes, and containerd teardown playbook
- `cns.sh`: wrapper script for combined or split install and uninstall flows, and help

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

To install only Kubernetes and Calico, run:

```bash
./cns.sh install-kubernetes
```

To install the GPU Operator later on an existing cluster, run:

```bash
./cns.sh install-gpu-operator
```

To remove everything installed by the deployment playbook, run:

```bash
./cns.sh uninstall
```

To remove only the GPU Operator, run:

```bash
./cns.sh uninstall-gpu-operator
```

To remove Calico, Kubernetes, and containerd, run:

```bash
./cns.sh uninstall-kubernetes
```

To see the available wrapper commands, run:

```bash
./cns.sh help
```

The wrapper calls `ansible-playbook playbook.yml` for full installs and `ansible-playbook uninstall.yml` for full teardown.
`playbook.yml` imports `kubernetes.yml` first and then `gpu-operator.yml`.
`uninstall.yml` imports `uninstall-gpu-operator.yml` first and then `uninstall-kubernetes.yml`.

## Notes

- The inventory is set up for one control plane node plus optional worker nodes.
- If you want a stable virtual IP or load balancer for the API server, set `control_plane_endpoint` in `group_vars/all.yml`.
- Kubernetes packages are placed on hold after installation, which is the standard kubeadm baseline.
- `gpu-operator.yml` expects Kubernetes to be initialized already and will fail fast if `/etc/kubernetes/admin.conf` is missing on the first control-plane node.
- By default `cns_version_file` points to `cns_versions/cns-v1.34.6.txt`. Override it with another file under `cns_versions/` when needed.
