#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_help() {
  cat <<'EOF'
Usage:
  ./cns.sh install [ansible-playbook options]
  ./cns.sh install-kubernetes [ansible-playbook options]
  ./cns.sh install-gpu-operator [ansible-playbook options]
  ./cns.sh uninstall [ansible-playbook options]
  ./cns.sh uninstall-gpu-operator [ansible-playbook options]
  ./cns.sh uninstall-kubernetes [ansible-playbook options]
  ./cns.sh help

Commands:
  install               Run the full deployment (kubernetes.yml, then gpu-operator.yml).
  install-kubernetes    Run only the Kubernetes and Calico deployment playbook (kubernetes.yml).
  install-gpu-operator  Run only the Helm and NVIDIA GPU Operator deployment playbook (gpu-operator.yml).
  uninstall             Run the full teardown (uninstall-gpu-operator.yml, then uninstall-kubernetes.yml).
  uninstall-gpu-operator  Run only the NVIDIA GPU Operator teardown playbook (uninstall-gpu-operator.yml).
  uninstall-kubernetes  Run the Calico and Kubernetes teardown playbook (uninstall-kubernetes.yml).
  help                  Show this help message.

Examples:
  ./cns.sh install
  ./cns.sh install-kubernetes
  ./cns.sh install-gpu-operator
  ./cns.sh uninstall
  ./cns.sh uninstall-gpu-operator
  ./cns.sh uninstall-kubernetes
  ./cns.sh install -e cns_version_file=cns_versions/cns-v1.35.3.txt
  ./cns.sh install-gpu-operator -e cns_version_file=cns_versions/cns-v1.35.3.txt
  ./cns.sh uninstall-kubernetes --check
  ./cns.sh uninstall --check
EOF
}

if [[ $# -lt 1 ]]; then
  show_help
  exit 1
fi

command="$1"
shift

case "$command" in
  install)
    exec ansible-playbook "${SCRIPT_DIR}/playbook.yml" "$@"
    ;;
  install-kubernetes)
    exec ansible-playbook "${SCRIPT_DIR}/kubernetes.yml" "$@"
    ;;
  install-gpu-operator)
    exec ansible-playbook "${SCRIPT_DIR}/gpu-operator.yml" "$@"
    ;;
  uninstall)
    exec ansible-playbook "${SCRIPT_DIR}/uninstall.yml" "$@"
    ;;
  uninstall-gpu-operator)
    exec ansible-playbook "${SCRIPT_DIR}/uninstall-gpu-operator.yml" "$@"
    ;;
  uninstall-kubernetes)
    exec ansible-playbook "${SCRIPT_DIR}/uninstall-kubernetes.yml" "$@"
    ;;
  help|-h|--help)
    if [[ $# -gt 0 ]]; then
      echo "The help command does not accept additional arguments." >&2
      exit 1
    fi
    show_help
    ;;
  *)
    echo "Unknown command: $command" >&2
    echo >&2
    show_help
    exit 1
    ;;
esac
