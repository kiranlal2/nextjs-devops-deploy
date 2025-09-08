pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = "kiranlal369"
        IMAGE_NAME      = "nextjs-devops-deploy"
        EC2_USER        = "ubuntu"
        EC2_HOST        = "13.48.138.171"
        PEM_KEY         = "/var/lib/jenkins/nextjs-devops-deploy.pem"
    }

    options {
        timeout(time: 30, unit: 'MINUTES')
    }

    stages {
        stage('Clean Workspace & Clone Repo') {
            steps {
                cleanWs()  // Clean before checkout
                checkout([$class: 'GitSCM', branches: [[name: 'main']], userRemoteConfigs: [[url: 'https://github.com/kiranlal2/nextjs-devops-deploy.git']]])
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build --pull --no-cache -t ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest ."
                }
                stash name: 'docker-image', includes: '**/*'
            }
        }

        // Input step placed outside node/agent to avoid blocking executors
        stage('Deployment Approval') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    input message: 'Approve Deployment?', ok: 'Deploy'
                }
            }
        }

        stage('Push Docker Image & Deploy to EC2') {
            steps {
                unstash 'docker-image'

                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    script {
                        sh "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin"
                        sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
                    }
                }

                script {
                    sh """
                    ssh -o StrictHostKeyChecking=no -i ${PEM_KEY} ${EC2_USER}@${EC2_HOST} '
                      cd /path/to/docker-compose-directory &&
                      docker-compose pull &&
                      docker-compose up -d --build
                    '
                    """
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo '✅ Build and deployment successful!'
        }
        failure {
            echo '❌ Build failed. Check logs for details.'
        }
    }
}
