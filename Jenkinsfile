pipeline {
    agent any
    parameters {
    choice (name: "TARGET_NAMESPACE", choices: ["dev", "prod"], description: "Select the targert namespace" )    
    }
    environment {
        KUBE_NAMESPACE = "${TARGET_NAMESPACE}"
        DOC_REGISTRY = "ozidochub"
        APP_REPO_NAME = "hepapi"
        DOCKERHUB_CRED = credentials ("dochub")
        //KUBECONFIG = credentials ("multipass2")

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
                sh 'echo $DOCKERHUB_CRED_PSW | docker login -u $DOCKERHUB_CRED_USR --password-stdin'
                sh 'docker push "$DOC_REGISTRY/$APP_REPO_NAME:latest"'
            }
        }
 
        stage('Deploy to Kubernetes Cluster') {
            steps {
                sh script:'''
                    cd /var/lib/jenkins/workspace/hepapi/hepapitask
                    pwd
                    kubectl create namespace ${KUBE_NAMESPACE} || true
                    kubectl delete -f db-deploy.yaml -n ${KUBE_NAMESPACE} || true
                    kubectl delete -f app-deploy.yaml -n ${KUBE_NAMESPACE} || true
                    kubectl apply -f db-configmap.yaml -n ${KUBE_NAMESPACE}
                    kubectl apply -f db-deploy.yaml -n ${KUBE_NAMESPACE}
                '''
                script {
                    if ( "${KUBE_NAMESPACE}" == "prod" ) {
                        sh "sed -i 's/nodePort: 32222/nodePort: 32223/g' app-deploy.yaml"
                    }
                    sh "kubectl apply -f app-deploy.yaml -n ${KUBE_NAMESPACE}"
                }   
                
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