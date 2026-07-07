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

## YAML Definition

Add the following snippet to the script section of your `bitbucket-pipelines.yml` file:

```yaml
- pipe: docker://ghcr.io/eucleciojosias/helm-chart-publisher:latest
```

## Variables

| Variable            | Usage                                                                                             |
|---------------------|-----------------------------------------------------------------------------------------------------|

> _(*) = required variable. This variable needs to be specified always when using the pipe._

> _(**) = required variable. If this variable is configured as a repository, account or environment variable, it doesn't need to be declared in the pipe as it will be taken from the context. It can still be overridden when using the pipe._

---
