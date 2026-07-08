#!/usr/bin/env bash

set -e

echo "::group::🚀 Setup"
echo "====================================================================="
printf "\n== Helm Chart Publisher ==\n\n"

git config --global --add safe.directory /opt/atlassian/pipelines/agent/build

autobot_commit="Auto released package"

last_commit=$(git log --pretty=format:%s -1)
if [[ $last_commit == *"$autobot_commit"* ]]; then
  echo "Autobot commit, skipped!"
  exit 0
fi
echo "====================================================================="
echo "::endgroup::"

no_chart_dir=("." ".ci" ".dist" "published")
changed_dirs=$( git diff HEAD~1 --name-only | grep "\/" | cut -d '/' -f1 | sort | uniq)

echo "::group::📝 Diff"
echo "====================================================================="
echo "$(git log --pretty=format:"%h %s" -1)"
git diff HEAD~1 --name-only
echo "====================================================================="
echo "::endgroup::"

for chart_dir in $changed_dirs; do
  if [[ $(echo "${no_chart_dir[@]}" | fgrep -w $chart_dir) ]]; then
    continue
  fi

  echo "::group::📦 Chart: $chart_dir"
  echo "====================================================================="
  helm template "$chart_dir" || exit 1
  echo "====================================================================="

  # Increase version
  version=$(helm show chart "$chart_dir" | grep version | cut -d ' ' -f2)
  echo "OLD VERSION: $version"

  new_minor=$(echo "$version" | cut -d '.' -f3 | cut -d '-' -f1)
  new_minor=$(expr $new_minor + 1)
  new_version="${version%\.*}.${new_minor}"
  if [[ "$BITBUCKET_BRANCH" == "develop" ]]; then
    new_version="$new_version-alpha" # prerelease
  fi
  yq -yi ".version = \"$new_version\"" "$chart_dir/Chart.yaml"
  git add "$chart_dir/Chart.yaml"

  echo "NEW VERSION: $new_version"
  echo "====================================================================="

  # Publish
  package_file=$(helm package -d published/ "$chart_dir" | grep -o '[^ ]*\.tgz$')
  echo "PACKAGE FILE: $package_file"
  echo "::endgroup::"
done

if [[ "$(git status)" == *"nothing to commit"* ]]; then
  echo "No changes to charts, skipped!"
  exit 0
fi

echo "::group::📤 Publish"
echo "====================================================================="
helm repo index published
echo "PUBLISHED FILES:"
ls -1 published/
if [[ "$BITBUCKET_BRANCH" == "master" ]]; then
  git add published
  last_commit_sha=$(git rev-parse --short HEAD)
  git commit -m "$autobot_commit from: $last_commit_sha" --author="Helm Chart Publisher Automation <autobot@example.com>"

  git config http.${BITBUCKET_GIT_HTTP_ORIGIN}.proxy http://host.docker.internal:29418/
  git push origin $BITBUCKET_BRANCH
fi
echo "====================================================================="
echo "::endgroup::"
