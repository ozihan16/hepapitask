pipeline {
    agent any
    environment {
        DOC_REGISTRY="ozidochub"
        APP_REPO_NAME="hepapi"

    }
    stages {
        stage('Clone repo from Github') {
            steps {
                sh 'rm -rf hepapitask'
                sh 'git clone https://github.com/ozihan16/hepapitask.git'
                sh 'pwd'
                //sh 'cd /hepapi/hepapitask/app '
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build --force-rm -t "$DOC_REGISTRY/$APP_REPO_NAME:latest" hepapitask/app/'
                sh 'docker image ls'
            }
        }
        stage('Login and Push Image to Dockerhub') {
            steps {
                sh 'docker login --username ${CREDS_USR} --password ${CREDS_PSW}'
                sh 'docker push "$DOC_REGISTRY/$APP_REPO_NAME:latest"'
            }
        }
        stage('Deploy to Kubernetes Cluster') {
            steps {
                sh 'cd /var/lib/jenkins/workspace/hepapi/hepapitask'
                sh 'pwd'
                sh 'kubectl delete -f /hepapitask/db-deploy.yaml || true'
                sh 'kubectl delete -f /hepapitask/app-deploy.yaml || true'
                sh 'kubectl apply -f /hepapitask/db-configmap.yaml'
                sh 'kubectl apply -f /hepapitask/db-deploy.yaml'
                sh 'kubectl apply -f /hepapitask/app-deploy.yaml'
            }
        }

    }
    post {
        always {
            echo 'Deleting all local images'
            sh 'docker image prune -af'
        }
    }
}