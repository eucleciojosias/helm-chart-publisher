# Helm Chart Publisher

The pipe will:

- check if has any chart change in the last commit
- for each chart changed:
  - will increase a minor version from the last pacakge
  - will generate a new package into `packaged/`
- update the helm repo index
- commit the new packages and the new index
- push to the current branch

## YAML Definition

Add the following snippet to the script section of your `bitbucket-pipelines.yml` file:

```yaml
- pipe: example-org/helm-chart-publisher:main
```

## Variables

| Variable            | Usage                                                                                             |
|---------------------|---------------------------------------------------------------------------------------------------|

> _(*) = required variable. This variable needs to be specified always when using the pipe._

> _(**) = required variable. If this variable is configured as a repository, account or environment variable, it doesn't need to be declared in the pipe as it will be taken from the context. It can still be overridden when using the pipe._

---
