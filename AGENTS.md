# Repository Guidelines

Canonical GitHub repository: `https://github.com/fguillie/cns.git`

## Project Structure & Module Organization
This repository is an Ansible project for provisioning and tearing down a kubeadm-based Kubernetes cluster on Ubuntu with versions pinned by checked-in `cns_versions/cns-v*.txt` snapshots.

- `playbooks/`: playbook directory containing the split install and teardown entry points.
- `playbooks/playbook.yml`: full install entry point; imports `playbooks/kubernetes.yml` and then `playbooks/gpu-operator.yml`.
- `playbooks/kubernetes.yml`: Kubernetes install path; parses the selected `cns_version_file`, installs pinned Kubernetes and containerd packages, bootstraps the first control-plane node, installs Calico, labels the first control-plane node as a worker, removes its `NoSchedule` taint, and generates the worker join command.
- `playbooks/gpu-operator.yml`: GPU Operator install path; parses the selected `cns_version_file`, installs pinned Helm, and deploys the NVIDIA GPU Operator onto an existing cluster.
- `playbooks/tasks/parse_snapshot.yml`: shared task include that parses the selected `cns_version_file` and derives version facts for install playbooks.
- `playbooks/uninstall.yml`: full teardown entry point; imports `playbooks/uninstall-gpu-operator.yml` and then `playbooks/uninstall-kubernetes.yml`.
- `playbooks/uninstall-gpu-operator.yml`: GPU Operator teardown path; removes the Helm release and operator namespace from an existing cluster.
- `playbooks/uninstall-kubernetes.yml`: Kubernetes teardown path; removes Calico, runs `kubeadm reset`, purges Kubernetes and containerd packages, removes repo-managed config plus local Helm artifacts, drops apt repositories, and reloads systemd and sysctl state.
- `cns.sh`: preferred operator entry point for `install`, `install-kubernetes`, `install-gpu-operator`, `uninstall`, `uninstall-gpu-operator`, `uninstall-kubernetes`, and `help`; passes additional arguments straight through to `ansible-playbook`.
- `group_vars/all.yml`: cluster-wide defaults, including the default `cns_version_file` (`cns_versions/cns-v1.34.6.txt`), pod and service CIDRs, architecture maps, CRI socket, `control_plane_endpoint`, and GPU Operator namespace.
- `inventory/hosts.ini`: inventory groups and host connection variables. The default layout is one control-plane node plus optional workers.
- `cns_versions/`: checked-in CNS component version snapshots used by the install and teardown playbooks.
- `cns_versions/cns-v*.txt`: verified component version snapshots such as `cns_versions/cns-v1.34.6.txt` and `cns_versions/cns-v1.35.3.txt`.
- `ansible.cfg`: local Ansible defaults for inventory selection, host key checking, retry files, interpreter detection, and SSH pipelining.
- `README.md`: operator-facing usage and version matrix. Keep it aligned with wrapper behavior and supported snapshots.

Keep new shared variables in `group_vars/` and host-specific connection data in `inventory/`. Preserve the current topology assumption that the first control-plane node is intentionally schedulable.
Playbooks now live under `playbooks/`, so shared task includes should be referenced relative to that directory, for example `tasks/parse_snapshot.yml`.

## Build, Test, and Development Commands
Run commands from the repository root.

- `./cns.sh install`: run the full deployment with the default inventory and snapshot.
- `./cns.sh install-kubernetes`: run only the Kubernetes and Calico deployment with the default inventory and snapshot.
- `./cns.sh install-gpu-operator`: run only the Helm and GPU Operator deployment against an existing cluster.
- `./cns.sh install -e cns_version_file=cns_versions/cns-v1.35.3.txt`: install from a different pinned snapshot.
- `./cns.sh uninstall`: remove all repo-managed Kubernetes, Calico, Helm, and containerd state.
- `./cns.sh uninstall-gpu-operator`: remove only the NVIDIA GPU Operator release and namespace.
- `./cns.sh uninstall-kubernetes`: remove Calico, Kubernetes, containerd state, and local Helm artifacts.
- `./cns.sh help`: show wrapper usage and examples.
- `ansible-playbook --syntax-check playbooks/playbook.yml`: validate install playbook syntax.
- `ansible-playbook --syntax-check playbooks/kubernetes.yml`: validate the Kubernetes install playbook syntax.
- `ansible-playbook --syntax-check playbooks/gpu-operator.yml`: validate the GPU Operator playbook syntax.
- `ansible-playbook --syntax-check playbooks/uninstall.yml`: validate teardown playbook syntax.
- `ansible-playbook --syntax-check playbooks/uninstall-gpu-operator.yml`: validate the GPU Operator teardown playbook syntax.
- `ansible-playbook --syntax-check playbooks/uninstall-kubernetes.yml`: validate the Kubernetes teardown playbook syntax.
- `ansible-playbook playbooks/playbook.yml --check`: dry-run supported install tasks.
- `ansible-playbook playbooks/uninstall.yml --check`: dry-run supported teardown tasks when changing idempotent removal logic.
- `ansible-inventory --list`: confirm inventory parsing and group membership under `ansible.cfg`.

Keep `cns.sh`, `README.md`, and `AGENTS.md` in sync when changing entry points, defaults, or supported operator flows.

## Coding Style & Naming Conventions
Use two-space YAML indentation and lowercase snake_case variable names such as `pod_network_cidr`. Prefer fully qualified module names like `ansible.builtin.apt` and `ansible.builtin.copy`. Write short imperative task names. Favor idempotent modules over shell commands; when a command or shell task is necessary, set `creates`, `changed_when`, and `failed_when` explicitly.

Keep inventory examples scrubbed of real credentials and public IPs. Do not add secrets, tokens, or kubeconfigs to the repository.

## Testing Guidelines
There is no dedicated automated test suite in this repository. Minimum validation for changes is:

- syntax-check every touched playbook;
- run `ansible-inventory --list` when modifying inventory structure or `ansible.cfg`;
- use `--check` for idempotent task changes where Ansible supports dry runs;
- inspect wrapper help output when changing `cns.sh`.

If a change affects the snapshot format or parsing logic, verify both existing `cns_versions/cns-v*.txt` files still work with the playbooks.

## Commit & Pull Request Guidelines
Git history may be unavailable in some workspaces, so use short imperative commit subjects such as `Add Helm passthrough example` or `Guard missing snapshot file`. Keep each commit focused on one logical change.

PRs should include a concise summary, affected files, validation commands run, and any operator-visible changes to inventory layout, defaults, or version snapshots.

## Security & Configuration Tips
`inventory/hosts.ini` supports inline SSH and sudo credentials for convenience. Do not commit real passwords. Prefer Ansible Vault or environment-specific inventory files outside the repo when possible.

Because installs are driven by checked-in `cns_versions/cns-v*.txt` snapshots, verify version numbers and snapshot formatting before changing the default `cns_version_file` or adding a new snapshot. The playbooks currently support Ubuntu targets only.

## Operational Notes
On single-node deployments, the install playbook intentionally makes the first control-plane node schedulable by adding the `worker` role label and removing the control-plane `NoSchedule` taint. The GPU Operator Helm install also adds a control-plane toleration for node-feature-discovery garbage collection. Keep node labels, taints, and Helm values aligned with that topology.

The control-plane endpoint is optional. If operators need a stable API server address, set `control_plane_endpoint` in `group_vars/all.yml` before installation.
