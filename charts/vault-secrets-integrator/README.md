# Vault-Secrets-Integrator
A deployment which utilises the [vault sidecar injector]() and converts vault secrets into kubernetes secrets

# Default Values
| Setting | Value | Description |
| ------- | ----- | ----------- |
| image.repository | bitnami/kubectl | Docker image containing kubectl |
| cronjob.failedJobsHistoryLimit | 3 | Max failed jobs to keep for interrogation|
| cronjob.successfulJobsHistoryLimit | 3 | Max successful jobs to keep for interrogation |
| cronjob.schedule | "* * * * *" | Frequency of cronjob execution |
| vault.engine.annotations | [] | vault engine name and path. Refer to values.yaml for sample format |
| vault.engine.role | "" | Role set on vault server to be used for procurring secrets |