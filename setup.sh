#!/bin/bash

# Setup script for local development environment
# This script sets up Jenkins locally and Minikube for testing

set -e

echo "🚀 Setting up Jenkins-K8s Local Development Environment"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if required tools are installed
check_requirements() {
    echo "🔍 Checking requirements..."
    
    commands=("docker" "kubectl" "minikube")
    for cmd in "${commands[@]}"; do
        if command -v $cmd &> /dev/null; then
            print_status "$cmd is installed"
        else
            print_error "$cmd is not installed. Please install it first."
            exit 1
        fi
    done
}

# Start Minikube
start_minikube() {
    echo "🎯 Starting Minikube..."
    
    if minikube status &> /dev/null; then
        print_status "Minikube is already running"
    else
        print_status "Starting Minikube..."
        minikube start --driver=docker --cpus=2 --memory=4096
        minikube addons enable ingress
    fi
    
    # Set kubectl context
    kubectl config use-context minikube
    print_status "Kubectl context set to Minikube"
}

# Start Jenkins locally
start_jenkins() {
    echo "🏗️  Starting Jenkins..."
    
    if docker ps | grep jenkins-local &> /dev/null; then
        print_status "Jenkins is already running"
    else
        print_status "Starting Jenkins with Docker Compose..."
        docker-compose up -d jenkins
        
        echo "⏳ Waiting for Jenkins to start..."
        sleep 30
        
        # Get initial admin password
        if docker ps | grep jenkins-local &> /dev/null; then
            echo "🔑 Getting Jenkins initial admin password..."
            docker exec jenkins-local cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "Password will be available after Jenkins fully starts"
        fi
    fi
}

# Build and test the application locally
build_and_test() {
    echo "🔨 Building and testing the application..."
    
    # Build Docker image
    docker build -t jenkins-k8s-demo:local .\n    print_status "Docker image built successfully"
    
    # Test the application
    echo "🧪 Testing the application..."
    docker run -d -p 5001:5000 --name test-app jenkins-k8s-demo:local
    sleep 5
    
    # Check if app is running
    if curl -s http://localhost:5001/health > /dev/null; then
        print_status "Application test passed!"
        docker stop test-app && docker rm test-app
    else
        print_error "Application test failed!"
        docker stop test-app && docker rm test-app
        exit 1
    fi
}

# Deploy to Minikube
deploy_to_minikube() {
    echo "🚢 Deploying to Minikube..."
    
    # Load Docker image into Minikube
    minikube image load jenkins-k8s-demo:local
    
    # Update deployment to use local image
    sed -i.bak 's|your-dockerhub-username/jenkins-k8s-demo:latest|jenkins-k8s-demo:local|g' k8s/deployment.yaml
    
    # Apply Kubernetes manifests
    kubectl apply -f k8s/
    
    # Wait for deployment
    kubectl rollout status deployment/jenkins-k8s-demo --timeout=300s
    
    print_status "Application deployed to Minikube!"
    
    # Get service URL
    echo "🌐 Getting service URL..."
    minikube service jenkins-k8s-demo-nodeport --url
}

# Display access information
show_access_info() {
    echo ""
    echo "🎉 Setup Complete! Access your services:"
    echo "======================================="
    
    if docker ps | grep jenkins-local &> /dev/null; then
        echo "🏗️  Jenkins: http://localhost:8080"
        echo "   Initial admin password:"
        docker exec jenkins-local cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "   (Password will be available after Jenkins fully starts)"
    fi
    
    echo ""
    echo "🚢 Minikube Services:"
    kubectl get services
    
    echo ""
    echo "📱 Access your app:"
    minikube service jenkins-k8s-demo-nodeport --url
    
    echo ""
    echo "🛠️  Useful commands:"
    echo "   minikube dashboard    - Open Kubernetes dashboard"
    echo "   kubectl get pods      - View running pods"
    echo "   kubectl logs <pod>    - View pod logs"
    echo "   docker-compose logs   - View Jenkins logs"
}

# Main execution
main() {
    check_requirements
    start_minikube
    start_jenkins
    build_and_test
    deploy_to_minikube
    show_access_info
}

# Run main function
main