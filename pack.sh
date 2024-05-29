#!/usr/bin/env bash

set -e
printf "
  ____ ___ ____  _____    _    ____  __  __
 / ___|_ _|  _ \| ____|  / \  |  _ \|  \/  |
 \___ \| || | | |  _|   / _ \ | |_) | |\/| |
  ___) | || |_| | |___ / ___ \|  _ <| |  | |
 |____/___|____/|_____/_/   \_\_| \_\_|  |_|

"

git config --global --add safe.directory /opt/atlassian/pipelines/agent/build

last_commit=$(git log --pretty=format:%s -1)
if [[ $last_commit == *"Auto released package"* ]]; then
  echo "Autobot commit, skipped!"
  exit 0
fi

no_chart_dir=("." ".ci" ".dist" "packaged")
changed_dirs=$(git diff HEAD~1 --name-only | xargs dirname | xargs dirname | sort | uniq)
if [[ "$changed_dirs" == "." ]]; then
  changed_dirs=$(git diff HEAD~1 --name-only | xargs dirname | sort | uniq)
fi

echo "======================================================="
echo "$(git log --pretty=format:"%h %s" -1)"
git diff HEAD~1 --name-only
echo "======================================================="

for chart_dir in $changed_dirs; do
  if [[ $(echo ${no_chart_dir[@]} | fgrep -w $chart_dir) ]]; then
    continue
  fi

  echo "CHART: $chart_dir"
  echo "======================================================="
  helm template "$chart_dir" || exit 1
  echo "======================================================="

  # Increase version
  version=$(helm show chart "$chart_dir" | grep version | cut -d ' ' -f2)
  echo "OLD VERSION: $version"

  new_minor=$(echo "$version" | cut -d '.' -f3)
  new_minor=$(expr $new_minor + 1)
  new_version="${version%\.*}.${new_minor}"
  yq -yi ".version = \"$new_version\"" "$chart_dir/Chart.yaml"
  git add "$chart_dir/Chart.yaml"

  echo "NEW VERSION: $new_version"
  echo "======================================================="

  # Pack
  helm package -d packaged/ "$chart_dir"
done

if [[ "$(git status)" == *"nothing to commit"* ]]; then
  echo "No changes to charts, skipped!"
  exit 0
fi

helm repo index packaged
git add packaged
last_commit_sha=$(git rev-parse --short HEAD)
git commit -m "Auto released package from: $last_commit_sha" --author="Helm Chart Publisher Automation <autobot@example.com>"

git config http.${BITBUCKET_GIT_HTTP_ORIGIN}.proxy http://host.docker.internal:29418/
git push origin $BITBUCKET_BRANCH
