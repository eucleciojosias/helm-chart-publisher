# Helm Chart Publisher

A Bitbucket Pipe that automates packaging and publishing Helm charts.

The pipe will:

- check if any chart changed in the last commit
- for each chart changed:
  - increase a minor version from the last package
  - generate a new package into `packaged/`
- update the Helm repo index
- commit the new packages and the new index
- push to the current branch

Source is hosted on GitHub; the Docker image is built by GitHub Actions
(`.github/workflows/build.yml`) and published to the GitHub Container
Registry.
