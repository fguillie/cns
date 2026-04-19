# Repository Guidelines

## Project Structure & Module Organization
This repository is an Ansible project for provisioning and tearing down a kubeadm-based Kubernetes cluster on Ubuntu.

- `playbook.yml`: install path; reads pinned versions from a selected `cns-v*.txt` snapshot, installs Kubernetes, containerd, Calico, Helm, and the NVIDIA GPU Operator, labels the first control-plane node as a worker, removes its `NoSchedule` taint, then joins workers.
- `uninstall.yml`: teardown path; removes GPU Operator and Calico, resets kubeadm state, purges Kubernetes/containerd packages, and cleans repo-managed config.
- `cns.sh`: preferred operator entry point for `install`, `uninstall`, and `help`.
- `inventory/hosts.ini`: inventory groups and host connection variables.
- `group_vars/all.yml`: cluster-wide defaults, including `cns_version_file`, network CIDRs, CRI socket, and optional `control_plane_endpoint`.
- `cns-v*.txt`: verified component version snapshots such as `cns-v1.35.3.txt` and `cns-v1.34.6.txt`.
- `ansible.cfg`: local Ansible defaults for inventory path, SSH behavior, and Python interpreter detection.

Keep new variables in `group_vars/` and host-specific values in `inventory/`. The default cluster pattern is a single-node control-plane that is also schedulable as a worker.

## Build, Test, and Development Commands
Use the wrapper from the repository root for routine operations.

- `./cns.sh install`: run the full cluster deployment.
- `./cns.sh uninstall`: remove everything managed by the playbooks.
- `./cns.sh help`: show supported wrapper commands.
- `ansible-playbook playbook.yml -e cns_version_file=cns-v1.34.6.txt`: install from a specific pinned snapshot.
- `ansible-playbook --syntax-check playbook.yml`: validate playbook syntax before pushing changes.
- `ansible-playbook --syntax-check uninstall.yml`: validate teardown changes.
- `ansible-playbook playbook.yml --check`: dry-run supported task changes.
- `ansible-inventory --list`: confirm inventory parsing and group membership.

Keep `cns.sh` and `README.md` in sync when adding entry points.

## Coding Style & Naming Conventions
Use two-space YAML indentation and lowercase snake_case keys such as `pod_network_cidr`. Prefer fully qualified module names like `ansible.builtin.apt`. Write short imperative task names. Keep secrets and real IPs out of committed examples.

## Testing Guidelines
There is no dedicated automated test suite in this repository. Minimum validation for changes is:

- syntax check both playbooks when touched;
- inspect inventory resolution with `ansible-inventory --list`;
- use `--check` when changing idempotent tasks.

Favor idempotent modules over raw shell commands and use `creates`, `changed_when`, or `failed_when` where needed.

## Commit & Pull Request Guidelines
Git history is not available in this workspace, so use short imperative commit subjects such as `Add worker join token guard`. Keep commits focused on one logical change.

PRs should include a concise summary, affected files, validation commands run, and any operator-visible inventory or variable changes.

## Security & Configuration Tips
`inventory/hosts.ini` currently supports inline SSH and sudo credentials. Do not commit real secrets. Prefer Ansible Vault or environment-specific inventory files. Because installs are driven by `cns-v*.txt` snapshots, verify version numbers before changing a snapshot or switching the default `cns_version_file`.

## Operational Notes
On single-node deployments, the install playbook intentionally makes the first control-plane node schedulable by adding the `worker` role label and removing the control-plane `NoSchedule` taint. Keep node-role labels, taints, and chart tolerations aligned with that topology.
