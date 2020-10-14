pipeline {

  agent {
    node { label 'mgt_slave' }
  }

  options {
 
    timeout(time: 4, unit: 'HOURS')
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }
  parameters {
    string(name: 'REVISION_ID', defaultValue: '', description: '(Optional) Differential Revision ID')
    string(name: 'DIFF_ID', defaultValue: '', description: '(Optional) Diff Id for a Differential Revision')
    string(name: 'PHID', defaultValue: '', description: '(Optional) Buildable PHID')
    string(name: 'STGREF', defaultValue: '', description: '(Optional) Staging repo tag/ref to be built')
    string(name: 'BRANCH_NAME', defaultValue: 'master', description: '(Optional) Branch Name')
    string(name: 'COMMIT_ID', defaultValue: 'HEAD', description: '(Optional) Commit id')
    string(name: 'SKIP_TESTS', defaultValue: '', description: '(Optional) Skip Tests if not-empty')
    string(name: 'DO_RELEASE', defaultValue: '', description: '(Optional)Pass a release version to build a release')
    string(name: 'HELMCHART_PATH', defaultValue: 'charts/*', description: '(Optional)Helm Chart repository location')
    string(name: 'HELM_REPOSITORY', defaultValue: 'https://nexus.gwdc.org.au/repository/helm/', description: '(Optional)Helm Artifact repository')
    string(name: 'OUT_PATH', defaultValue: '.tmp', description: '(Optional)Archive Path')
    // string(name: 'HELM_REPOSITORY_CREDENTIAL', defaultValue: "", description: '(Optional)Helm Artifact Repo Credentials')
  }


  stages {
    stage('Code lint') {
      steps {
        sh "helm lint $HELMCHART_PATH"
      }
    }
    stage('Helm Chart Dependency Validation') {
      steps{
        script {
          sh '''
          # Temporary Repo
          helm repo add gwcloud $HELM_REPOSITORY
          
          # List the dependencies for the given chart
          for dir in $HELMCHART_PATH; do (echo "====" && helm dependency list "$dir"); done

          # Rebuild the charts/ directory based on the Chart.lock file
          for dir in $HELMCHART_PATH; do (echo "====" && helm dependency build "$dir"); done
          '''
        }
      }
    }
    stage('Packaging Helm Chart') {
      steps{
        script {
          sh "helm package $HELMCHART_PATH -d $OUT_PATH"
        }
      }
    }
    stage('Uploading Image') {
      steps{
        withCredentials([usernameColonPassword(credentialsId: "$HELM_REPOSITORY_CREDENTIAL", variable: 'USERPASS')]) {
            sh '''
            set +x
            for TGZ in $OUT_PATH; do (echo "====" && curl -u $USERPASS $HELM_REPOSITORY --upload-file $TGZ); done
            '''
        }
      }
    }
    stage('Post Deployment Validation') {
      steps{
        script {
            sh '''
            for TGZ in .tmp ; do ls $TGZ | helm search repo gwcloud/$(sed 's/\\.tgz//') ; done
            '''
        }
      }
    }
    stage('Cleanup') {
      steps{
        sh '''
        # Helm Repo
        helm repo rm gwcloud
        
        # Build Artefacts
        rm -rf $OUT_PATH
        '''
      }
    }
  }
}
