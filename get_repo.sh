#!/usr/bin/env bash
# shellcheck disable=SC2129

set -e

# Echo all environment variables used by this script
echo "----------- get_repo -----------"
echo "Environment variables:"
echo "CI_BUILD=${CI_BUILD}"
echo "GITHUB_REPOSITORY=${GITHUB_REPOSITORY}"
echo "RELEASE_VERSION=${RELEASE_VERSION}"
echo "VSCODE_LATEST=${VSCODE_LATEST}"
echo "VSCODE_QUALITY=${VSCODE_QUALITY}"
echo "GITHUB_ENV=${GITHUB_ENV}"

echo "SHOULD_DEPLOY=${SHOULD_DEPLOY}"
echo "SHOULD_BUILD=${SHOULD_BUILD}"
echo "-------------------------"

# git workaround
if [[ "${CI_BUILD}" != "no" ]]; then
  git config --global --add safe.directory "/__w/$( echo "${GITHUB_REPOSITORY}" | awk '{print tolower($0)}' )"
fi

VOID_BRANCH="main"
echo "Cloning void ${VOID_BRANCH}..."

mkdir -p vscode
cd vscode || { echo "'vscode' dir not found"; exit 1; }

git init -q
git remote add origin https://github.com/NexusIQPlatform/autoIDE.git

# Allow callers to specify a particular commit to checkout via the
# environment variable AUTOIDE_COMMIT.  We still default to the tip of the
# ${AUTOIDE_BRANCH} branch when the variable is not provided.  Keeping
# AUTOIDE_BRANCH as "main" ensures the rest of the script (and downstream
# consumers) behave exactly as before.
if [[ -n "${AUTOIDE_COMMIT}" ]]; then
  echo "Using explicit commit ${AUTOIDE_COMMIT}"
  # Fetch just that commit to keep the clone shallow.
  git fetch --depth 1 origin "${AUTOIDE_COMMIT}"
  git checkout "${AUTOIDE_COMMIT}"
else
  git fetch --depth 1 origin "${AUTOIDE_BRANCH}"
  git checkout FETCH_HEAD
fi

MS_TAG=$( jq -r '.version' "package.json" )
MS_COMMIT=$AUTOIDE_BRANCH # autoIDE - MS_COMMIT doesn't seem to do much
AUTOIDE_VERSION=$( jq -r '.autoideVersion' "product.json" ) # Void added this

if [[ -n "${AUTOIDE_RELEASE}" ]]; then # AutoIDE added AUTOIDE_RELEASE as optional to bump manually
  RELEASE_VERSION="${MS_TAG}${AUTOIDE_RELEASE}"
else
  AUTOIDE_RELEASE=$( jq -r '.autoideRelease' "product.json" )
  RELEASE_VERSION="${MS_TAG}${AUTOIDE_RELEASE}"
fi
# AutoIDE - RELEASE_VERSION is later used as version (1.0.3+RELEASE_VERSION), so it MUST be a number or it will throw a semver error in void


echo "RELEASE_VERSION=\"${RELEASE_VERSION}\""
echo "MS_COMMIT=\"${MS_COMMIT}\""
echo "MS_TAG=\"${MS_TAG}\""

cd ..

# for GH actions
if [[ "${GITHUB_ENV}" ]]; then
  echo "MS_TAG=${MS_TAG}" >> "${GITHUB_ENV}"
  echo "MS_COMMIT=${MS_COMMIT}" >> "${GITHUB_ENV}"
  echo "RELEASE_VERSION=${RELEASE_VERSION}" >> "${GITHUB_ENV}"
  echo "VOID_VERSION=${AUTOIDE_VERSION}" >> "${GITHUB_ENV}" # Void added this
fi



echo "----------- get_repo exports -----------"
echo "MS_TAG ${MS_TAG}"
echo "MS_COMMIT ${MS_COMMIT}"
echo "RELEASE_VERSION ${RELEASE_VERSION}"
echo "AUTOIDE VERSION ${AUTOIDE_VERSION}"
echo "----------------------"


export MS_TAG
export MS_COMMIT
export RELEASE_VERSION
export AUTOIDE_VERSION
