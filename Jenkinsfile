pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = "kiranlal369"
        IMAGE_NAME = "nextjs-devops-deploy"
        EC2_USER = "ubuntu"
        EC2_HOST = "13.62.45.219"
        PEM_KEY = "/var/lib/jenkins/nextjs-devops-deploy.pem"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/kiranlal2/nextjs-devops-deploy.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh '''
                      echo "✅ Building Docker image..."
                      docker build -t $DOCKER_HUB_USER/$IMAGE_NAME:latest .
                    '''
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                                      usernameVariable: 'DOCKER_USER',
                                                      passwordVariable: 'DOCKER_PASS')]) {
                        sh '''
                          echo "✅ Logging into Docker Hub..."
                          echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                          docker push $DOCKER_HUB_USER/$IMAGE_NAME:latest
                        '''
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    sh '''
                      echo "🚀 Deploying on EC2..."
                      ssh -o StrictHostKeyChecking=no -i $PEM_KEY $EC2_USER@$EC2_HOST << 'EOF'
                        docker pull $DOCKER_HUB_USER/$IMAGE_NAME:latest
                        docker stop nextjsapp || true
                        docker rm nextjsapp || true
                        docker run -d --name nextjsapp -p 3000:3000 $DOCKER_HUB_USER/$IMAGE_NAME:latest
                        sudo systemctl restart nginx
                      EOF
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment completed successfully!"
        }
        failure {
            echo "❌ Deployment failed! Check Jenkins logs."
        }
    }
}
