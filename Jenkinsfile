pipeline {
    agent any

    options {
        timeout(time: 30, unit: 'MINUTES')
        // Do not put cleanWs here as an option - this causes error
    }

    stages {
        stage('Clone Repository') {
            steps {
                cleanWs()  // Clean workspace before checkout
                checkout([$class: 'GitSCM', branches: [[name: 'main']], userRemoteConfigs: [[url: 'https://github.com/kiranlal2/nextjs-devops-deploy.git']]])
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build --pull --no-cache -t ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    script {
                        sh "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin"
                        sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    sh """
                    ssh -o StrictHostKeyChecking=no -i ${PEM_KEY} ${EC2_USER}@${EC2_HOST} '
                      cd /path/to/your/docker-compose-directory &&
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
            cleanWs()  // Clean workspace after build completes
        }
        success {
            echo '✅ Build and deployment successful!'
        }
        failure {
            echo '❌ Build failed. Review logs and optimize resource usage!'
        }
    }
}
