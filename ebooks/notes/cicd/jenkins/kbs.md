## Jenkinsfile with generic webhook
```groovy
pipeline {
    agent {
        label 'win-agent-2019'
    }

    triggers {
        GenericTrigger(causeString: 'Generic Cause', 
                    genericVariables: [
                        [defaultValue: '', key: 'branch', regexpFilter: '^(refs/heads/|refs/remotes/origin/)', value: '$.ref'], 
                        [defaultValue: '', key: 'repository', regexpFilter: '', value: '$.repository.name'], 
                    ], 
                    printPostContent: true, 
                    regexpFilterExpression: 'Core2D\\smaster',
                    regexpFilterText: '$repository $branch', 
                    token: 'core2d12345678'
        )
    }

    options {
        disableConcurrentBuilds()
        skipDefaultCheckout true
        ansiColor('xterm')
        gitLabConnection('gitlab_xxxx')
        gitlabBuilds(builds: ['core2d'])
    }

    environment {
        GITREPO = "git@gitlab.xxxx.com:sample/core2d.git"
        ARTIFACT_SERVER = "www.xxxx.com"
        APP_NAME = "core2d"
    }

    stages {
        stage("Checkout") {
            steps {
                checkout([
                    $class: 'GitSCM', 
                    branches: [[name: '*/master']], 
                    doGenerateSubmoduleConfigurations: false, 
                    extensions: [
                        [$class: 'CloneOption', noTags: false, shallow: false, timeout: 10], 
                        [$class: 'CheckoutOption', timeout: 10]
                    ], 
                    submoduleCfg: [], 
                    userRemoteConfigs: [
                        [credentialsId: 'ssh_private_key_agent2gitlab', url: "${GITREPO}"]
                    ]
                ])

                updateGitlabCommitStatus name: "${APP_NAME}", state: 'running'
            }
        }
        stage('Prepare') {
            steps {
                script{
                    def versionProp = readProperties  file: "${WORKSPACE}/version"
                    def majorVersion = versionProp['major']
                    def minorVersion = versionProp['minor']
                    def buildNumber = sh(
                        script: "git rev-list HEAD --count",
                        returnStdout: true
                    ).trim()

                    env.buildVersion = majorVersion + "." + minorVersion + "." + "${BUILD_NUMBER}"
                    currentBuild.displayName=sh(script: 'echo "#${BUILD_NUMBER} ${APP_NAME}-${buildVersion}"',returnStdout: true).trim()
                }
            }
        }
        stage('Build') {
            steps {
                powershell '''
                    $ErrorActionPreference = "Stop"
                    ./build.ps1
                '''
            }
        }
        stage('Package') {
            steps {
                powershell '''
                    $ErrorActionPreference = "Stop"
                    cd "src\\Core2D.Desktop\\bin\\Release"
                    mv net5.0 "${Env:APP_NAME}"
                    Compress-Archive "${Env:APP_NAME}" "${Env:APP_NAME}-${Env:buildVersion}.zip"
                '''
            }
        }
        stage('Post') {
            steps {
                powershell '''
                    $ErrorActionPreference = "Stop"
                    cp -Force "src\\Core2D.Desktop\\bin\\Release\\${Env:APP_NAME}-${Env:buildVersion}.zip" "\\\\${Env:ARTIFACT_SERVER}\\builds\\sample\\${Env:APP_NAME}\\"
                '''
            }
        }
    }
    post {
        aborted {
            updateGitlabCommitStatus name: "${APP_NAME}", state: 'canceled'
        }
        success {
            updateGitlabCommitStatus name: "${APP_NAME}", state: 'success'

            script{
                def packageLink = "https://${ARTIFACT_SERVER}/builds/sample/${APP_NAME}/${APP_NAME}-${buildVersion}.zip"
                def currentDesc = "Artifact: <a href='${packageLink}' target='_blank'>${APP_NAME}-${buildVersion}.zip</a>"
                currentBuild.description = currentDesc
            }
        }
        failure {
           updateGitlabCommitStatus name: "${APP_NAME}", state: 'failed'
        }

        always {
            script{
                emailext(
                    subject: '$PROJECT_NAME - Build # ' + env.buildVersion + '- $BUILD_STATUS!',
                    body: '$DEFAULT_CONTENT',
                    recipientProviders: [
                        [$class: 'CulpritsRecipientProvider'],
                        [$class: 'RequesterRecipientProvider'],
                        [$class : 'DevelopersRecipientProvider']
                    ],
                    replyTo: '$DEFAULT_REPLYTO',
                    to: 'cc:devops@xxxx.com'
                )
            }
        }
    }
}
```
> Integration with GitLab: 
> In Jenkinsfile, register a GitLab pipeline by “gitlabBuilds” and update status of GitLab commits by “updateGitlabCommitStatus”

**version**
```properties
major=1
minor=0
```