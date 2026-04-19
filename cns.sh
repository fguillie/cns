#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_help() {
  cat <<'EOF'
Usage:
  ./cns.sh install [ansible-playbook options]
  ./cns.sh uninstall [ansible-playbook options]
  ./cns.sh help

Commands:
  install    Run the Kubernetes cluster deployment playbook (playbook.yml).
  uninstall  Run the teardown playbook (uninstall.yml) to remove installed components.
  help       Show this help message.

Examples:
  ./cns.sh install
  ./cns.sh uninstall
  ./cns.sh install -e cns_version_file=cns-v1.35.3.txt
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
  uninstall)
    exec ansible-playbook "${SCRIPT_DIR}/uninstall.yml" "$@"
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
