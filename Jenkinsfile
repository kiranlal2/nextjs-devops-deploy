pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = "kiranlal369"
        IMAGE_NAME      = "nextjs-devops-deploy"
        EC2_USER        = "ubuntu"
        EC2_HOST        = "16.16.204.156"
        PEM_KEY         = "/var/lib/jenkins/nextjs-devops-deploy.pem"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/your-repo/nextjs-devops-deploy.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t $DOCKER_HUB_USER/$IMAGE_NAME:latest .'
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh 'docker push $DOCKER_HUB_USER/$IMAGE_NAME:latest'
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    sh """
                        ssh -o StrictHostKeyChecking=no -i $PEM_KEY $EC2_USER@$EC2_HOST '
                        docker pull $DOCKER_HUB_USER/$IMAGE_NAME:latest &&
                        docker stop nextjs-app || true &&
                        docker rm nextjs-app || true &&
                        docker run -d -p 80:80 --name nextjs-app $DOCKER_HUB_USER/$IMAGE_NAME:latest
                        '
                    """
                }
            }
        }
    }
}
