# Helm
Helm Chart repository for gwcloud applications

# SETUP
```bash
# Add helm chart repository
$ helm repo add gwcloud https://nexus.gw-cloud.org/repository/helm/

# Validation
$ helm search repo gwcloud

# Template Generation - K8s manifest generator
$ helm install $RELEASENAME gwcloud/$CHARTNAME
```

# DEVELOPMENT
```bash
# Create Template chart repository
$ helm create charts/$CHARTNAME

# List the dependencies for the given chart
$ helm dependency list charts/$CHARTNAME

# Rebuild the charts/ directory based on the Chart.lock file
$ helm dependency build charts/$CHARTNAME

# Update charts/ based on the contents of Chart.yaml
$ helm dependency update charts/$CHARTNAME

# Create k8s manifest template for sanity check
$ helm template charts/$CHARTNAME --output-dir $TMPDIR

# Generate Archive
$ helm package charts/$CHARTNAME -d $DESTINATIONPATH

# STORE ABSOLUTE FILE PATH TO ENV VAR
$ export CHART_ARCHIVE=$(find $OUT_PATH | grep tgz$)
```