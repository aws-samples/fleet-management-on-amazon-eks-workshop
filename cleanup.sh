#!/usr/bin/env bash

set -euo pipefail
set -o errexit

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR=$SCRIPTDIR
[[ -n "${DEBUG:-}" ]] && set -x


${ROOTDIR}/terraform/spokes/destroy.sh prod
${ROOTDIR}/terraform/spokes/destroy.sh staging
${ROOTDIR}/terraform/hub/destroy.sh
${ROOTDIR}/terraform/codecommit/destroy.sh

