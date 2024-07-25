#!/usr/bin/env bash

set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR=$SCRIPTDIR
[[ -n "${DEBUG:-}" ]] && set -x

GITOPS_DIR=${GITOPS_DIR:-$SCRIPTDIR/gitops-repos}

# Reset directory
rm -rf ${GITOPS_DIR}
mkdir -p ${GITOPS_DIR}

gitops_workload_url="$(terraform -chdir=${ROOTDIR}/terraform/codecommit output -raw gitops_workload_url)"
gitops_platform_url="$(terraform -chdir=${ROOTDIR}/terraform/codecommit output -raw gitops_platform_url)"
gitops_addons_url="$(terraform -chdir=${ROOTDIR}/terraform/codecommit output -raw gitops_addons_url)"

git clone ${gitops_workload_url} ${GITOPS_DIR}/apps
mkdir ${GITOPS_DIR}/apps/backend
touch ${GITOPS_DIR}/apps/backend/.keep
mkdir ${GITOPS_DIR}/apps/frontend
touch ${GITOPS_DIR}/apps/frontend/.keep
git -C ${GITOPS_DIR}/apps add . || true
git -C ${GITOPS_DIR}/apps commit -m "initial commit" || true
git -C ${GITOPS_DIR}/apps push  || true

# populate platform repository
git clone ${gitops_platform_url} ${GITOPS_DIR}/platform
mkdir -p ${GITOPS_DIR}/platform/charts && cp -r ${WORKSHOP_DIR}/gitops/platform/charts/*  ${GITOPS_DIR}/platform/charts/
mkdir -p ${GITOPS_DIR}/platform/bootstrap && cp -r ${WORKSHOP_DIR}/gitops/platform/bootstrap/*  ${GITOPS_DIR}/platform/bootstrap/
git -C ${GITOPS_DIR}/platform add. || true
git -C ${GITOPS_DIR}/platform commit -m "initial commit" || true
git -C ${GITOPS_DIR}/platform push || true

git clone ${gitops_addons_url} ${GITOPS_DIR}/addons
cp -r ${ROOTDIR}/gitops/addons/* ${GITOPS_DIR}/addons/
git -C ${GITOPS_DIR}/addons add . || true
git -C ${GITOPS_DIR}/addons commit -m "initial commit" || true
git -C ${GITOPS_DIR}/addons push  || true
