#!/usr/bin/env bash

set -eo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR=$SCRIPTDIR
DEBUG="${DEBUG:-}"
[[ -n "${DEBUG:-}" ]] && set -x
set -u


DEBUG=$DEBUG ${ROOTDIR}/terraform/hub/destroy.sh
DEBUG=$DEBUG ${ROOTDIR}/terraform/spokes/destroy.sh staging
DEBUG=$DEBUG ${ROOTDIR}/terraform/spokes/destroy.sh prod
DEBUG=$DEBUG ${ROOTDIR}/terraform/common/destroy.sh
