#!/usr/bin/env bash

set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR=$SCRIPTDIR
[[ -n "${DEBUG:-}" ]] && set -x

aws eks --region $AWS_DEFAULT_REGION update-kubeconfig --name hub-cluster --alias hub-cluster
aws eks --region $AWS_DEFAULT_REGION update-kubeconfig --name spoke-staging --alias staging-cluster
aws eks --region $AWS_DEFAULT_REGION update-kubeconfig --name spoke-prod --alias prod-cluster
