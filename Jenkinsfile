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
        cleanWs()
    }

    stages {
        stage('Clone Repository') {
            steps {
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
                        ssh -o StrictHostKeyChecking=no -i ${PEM_KEY} ${EC2_USER}@${EC2_HOST} "
                            docker pull ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest &&
                            docker rm -f nextjs-app || true &&
                            docker run -d -p 3000:3000 --restart unless-stopped --name nextjs-app ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest
                        "
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
            echo '❌ Build failed. Review logs and optimize resource usage!'
        }
    }
}
