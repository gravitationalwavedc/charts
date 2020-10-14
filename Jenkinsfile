pipeline {

  agent {
    node { label 'TEST' }
  }

  options {
 
    timeout(time: 4, unit: 'HOURS')
    timestamps()
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
    string(name: 'HELMCHART_PATH', defaultValue: 'charts', description: '(Optional)Pass a release version to build a release')
  }

  stages {
    stage('Code lint') {
      steps {
        sh "helm lint $HELMCHART_PATH/*"
      }
    }
    stage('Helm Chart Dependency Validation') {
      steps{
        script {
          sh '''
          # Temporary Repo
          helm repo add gwcloud $repository
          
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
        withCredentials([usernameColonPassword(credentialsId: "$repositoryCredential", variable: 'USERPASS')]) {
            sh '''
            export CHART_ARCHIVE=$(find $OUT_PATH | grep tgz$)
            set +x
            for TGZ in $OUT_PATH; do (echo "====" && curl -u $USERPASS $repository --upload-file $TGZ); done
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
