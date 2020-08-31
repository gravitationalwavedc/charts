# Helm
Helm Chart repository for gwcloud applications

# SETUP
```bash
# Add helm chart repository
$ helm repo add gwcloud https://nexus.gw-cloud.org/repository/helm/ 

# Validation
$ helm search repo gwcloud

# Template Generation - K8s manifest generator
$ helm install $RELEASENAME gwcloud/$APPLICATIONNAME
```

# DEVELOPMENT
```bash
# Generate Artifact
helm package $HELMCHARTPATH -d $DESTINATIONPATH

# STORE ABSOLUTE FILE PATH TO ENV VAR
export CHART_ARCHIVE=$(find $OUT_PATH | grep tgz$)
```