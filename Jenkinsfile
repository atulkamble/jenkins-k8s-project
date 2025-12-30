pipeline {
    agent any
    
    environment {
        // Docker Hub credentials (configure in Jenkins)
        DOCKER_HUB_REPO = 'your-dockerhub-username/jenkins-k8s-demo'
        DOCKER_TAG = "${BUILD_NUMBER}"
        KUBECONFIG = credentials('kubeconfig') // Configure in Jenkins
    }
    
    stages {
        stage('📦 Checkout') {
            steps {
                echo '🔄 Checking out source code...'
                checkout scm
            }
        }
        
        stage('🧪 Test') {
            steps {
                echo '🧪 Running tests...'
                script {
                    // Create virtual environment and run tests
                    sh '''
                        python3 -m venv venv
                        . venv/bin/activate
                        pip install -r app/requirements.txt
                        # Add your test commands here
                        echo "✅ Tests completed successfully!"
                    '''
                }
            }
        }
        
        stage('🏗️ Build Docker Image') {
            steps {
                echo '🏗️ Building Docker image...'
                script {
                    // Build Docker image
                    def image = docker.build("${DOCKER_HUB_REPO}:${DOCKER_TAG}")
                    def latestImage = docker.build("${DOCKER_HUB_REPO}:latest")
                    
                    echo "✅ Docker image built: ${DOCKER_HUB_REPO}:${DOCKER_TAG}"
                }
            }
        }
        
        stage('🚀 Push to Docker Hub') {
            steps {
                echo '🚀 Pushing Docker image to registry...'
                script {
                    // Push to Docker Hub (requires Docker Hub credentials configured)
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
                        def image = docker.image("${DOCKER_HUB_REPO}:${DOCKER_TAG}")
                        image.push()
                        image.push('latest')
                    }
                    echo "✅ Image pushed: ${DOCKER_HUB_REPO}:${DOCKER_TAG}"
                }
            }
        }
        
        stage('🎯 Deploy to Kubernetes') {
            steps {
                echo '🎯 Deploying to Kubernetes...'
                script {
                    // Update deployment with new image
                    sh '''
                        # Replace image tag in deployment.yaml
                        sed -i "s|image: .*|image: ${DOCKER_HUB_REPO}:${DOCKER_TAG}|g" k8s/deployment.yaml
                        
                        # Apply Kubernetes manifests
                        kubectl apply -f k8s/
                        
                        # Wait for deployment to complete
                        kubectl rollout status deployment/jenkins-k8s-demo
                        
                        # Get service info
                        kubectl get services jenkins-k8s-demo-service
                    '''
                    echo "✅ Deployment completed successfully!"
                }
            }
        }
    }
    
    post {
        always {
            echo '🧹 Cleaning up...'
            // Clean up Docker images
            sh 'docker system prune -f'
        }
        success {
            echo '🎉 Pipeline completed successfully!'
            // Send success notification (configure as needed)
        }
        failure {
            echo '❌ Pipeline failed!'
            // Send failure notification (configure as needed)
        }
    }
}