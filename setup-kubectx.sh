#!/usr/bin/env bash

set -uo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR=$SCRIPTDIR
[[ -n "${DEBUG:-}" ]] && set -x

aws eks --region $AWS_DEFAULT_REGION update-kubeconfig --name fleet-hub-cluster --alias fleet-hub-cluster 
aws eks --region $AWS_DEFAULT_REGION update-kubeconfig --name fleet-spoke-staging --alias fleet-staging-cluster
aws eks --region $AWS_DEFAULT_REGION update-kubeconfig --name fleet-spoke-prod --alias fleet-prod-cluster
