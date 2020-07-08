def dockerHubRepo = "icgcargo/workflow-gateway"
def githubRepo = "icgc-argo/workflow-gateway"
def chartVersion = "0.2.0"
def commit = "UNKNOWN"
def version = "UNKNOWN"

pipeline {
    agent {
        kubernetes {
            label 'wf-gateway'
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: helm
    image: alpine/helm:2.12.3
    command:
    - cat
    tty: true
  - name: docker
    image: docker:18-git
    tty: true
    volumeMounts:
    - mountPath: /var/run/docker.sock
      name: docker-sock
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
      type: File
  - name: docker-graph-storage
    emptyDir: {}
"""
        }
    }
    stages {
        stage('Prepare') {
            steps {
                script {
                    commit = sh(returnStdout: true, script: 'git describe --always').trim()
                    version = sh(returnStdout: true, script: 'head -1 VERSION').trim()
                }
            }
        }
        stage('Build & Publish Develop') {
            when {
                branch "develop"
            }
            steps {
                container('docker') {
                    withCredentials([usernamePassword(credentialsId:'argoDockerHub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh 'docker login -u $USERNAME -p $PASSWORD'
                    }

                    // DNS error if --network is default
                    sh "docker build --network=host . -t ${dockerHubRepo}:edge -t ${dockerHubRepo}:${version}-${commit}"

                    sh "docker push ${dockerHubRepo}:${version}-${commit}"
                    sh "docker push ${dockerHubRepo}:edge"
                }
            }
        }

        stage('deploy to rdpc-collab-dev') {
            when {
// Change branch to develop after successful testing
                branch "2020-07-08-add-jenkins-deploy-stage"
            }
            steps {
                build(job: "/provision/helm", parameters: [
                    [$class: 'StringParameterValue', name: 'AP_RDPC_ENV', value: 'dev' ],
                    [$class: 'StringParameterValue', name: 'AP_CHART_NAME', value: 'workflow-gateway'],
                    [$class: 'StringParameterValue', name: 'AP_RELEASE_NAME', value: 'gateway'],
                    [$class: 'StringParameterValue', name: 'AP_HELM_CHART_VERSION', value: "${chartVersion}"],
                    [$class: 'StringParameterValue', name: 'AP_ARGS_LINE', value: "--set-string image.tag=${version}-${commit}" ]
                ])
            }
        }

        stage('Release & Tag') {
            when {
                branch "master"
            }
            steps {
                container('docker') {
                    withCredentials([usernamePassword(credentialsId: 'argoGithub', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                        sh "git tag ${version}"
                      sh "git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/${githubRepo} --tags"
                    }

                    withCredentials([usernamePassword(credentialsId:'argoDockerHub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh 'docker login -u $USERNAME -p $PASSWORD'
                    }

                    // DNS error if --network is default
                    sh "docker build --network=host . -t ${dockerHubRepo}:latest -t ${dockerHubRepo}:${version}"

                    sh "docker push ${dockerHubRepo}:${version}"
                    sh "docker push ${dockerHubRepo}:latest"
                }
            }
        }
    }
}
