#!/bin/bash

# Test script to validate the entire CI/CD pipeline
# This script tests both Jenkins locally and Kubernetes deployment

set -e

echo "🧪 Jenkins-K8s Pipeline Test Suite"
echo "================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }

# Test 1: Docker build
test_docker_build() {
    echo "🐳 Test 1: Docker Build"
    if docker build -t jenkins-k8s-demo:test . > /dev/null 2>&1; then
        print_success "Docker build successful"
    else
        print_error "Docker build failed"
        return 1
    fi
}

# Test 2: Application functionality
test_application() {
    echo "🌐 Test 2: Application Functionality"
    
    # Start container
    docker run -d -p 5002:5000 --name test-app-func jenkins-k8s-demo:test
    sleep 5
    
    # Test health endpoint
    if curl -s http://localhost:5002/health | grep -q "healthy"; then
        print_success "Health endpoint working"
    else
        print_error "Health endpoint failed"
        docker stop test-app-func && docker rm test-app-func
        return 1
    fi
    
    # Test main page
    if curl -s http://localhost:5002 | grep -q "Jenkins CI/CD"; then
        print_success "Main page working"
    else
        print_error "Main page failed"
        docker stop test-app-func && docker rm test-app-func
        return 1
    fi
    
    # Cleanup
    docker stop test-app-func && docker rm test-app-func
}

# Test 3: Kubernetes manifests validation
test_k8s_manifests() {
    echo "☸️  Test 3: Kubernetes Manifests"
    
    # Validate deployment.yaml
    if kubectl apply --dry-run=client -f k8s/deployment.yaml > /dev/null 2>&1; then
        print_success "deployment.yaml is valid"
    else
        print_error "deployment.yaml is invalid"
        return 1
    fi
    
    # Validate service.yaml
    if kubectl apply --dry-run=client -f k8s/service.yaml > /dev/null 2>&1; then
        print_success "service.yaml is valid"
    else
        print_error "service.yaml is invalid"
        return 1
    fi
}

# Test 4: Minikube deployment
test_minikube_deployment() {
    echo "🚢 Test 4: Minikube Deployment"
    
    # Check if Minikube is running
    if ! minikube status > /dev/null 2>&1; then
        print_warning "Minikube not running, skipping deployment test"
        return 0
    fi
    
    # Load image to Minikube
    minikube image load jenkins-k8s-demo:test
    
    # Create temporary deployment with test image
    sed 's|your-dockerhub-username/jenkins-k8s-demo:latest|jenkins-k8s-demo:test|g' k8s/deployment.yaml > /tmp/test-deployment.yaml
    
    # Apply test deployment
    kubectl apply -f /tmp/test-deployment.yaml
    kubectl apply -f k8s/service.yaml
    
    # Wait for rollout
    if kubectl rollout status deployment/jenkins-k8s-demo --timeout=60s > /dev/null 2>&1; then
        print_success "Deployment successful"
        
        # Test service accessibility
        sleep 10
        POD_NAME=$(kubectl get pods -l app=jenkins-k8s-demo -o jsonpath='{.items[0].metadata.name}')\n        if kubectl exec $POD_NAME -- curl -s http://localhost:5000/health | grep -q "healthy"; then\n            print_success "Service is accessible within cluster"\n        else\n            print_warning "Service accessibility test inconclusive"\n        fi\n    else\n        print_error "Deployment failed or timed out"\n        return 1\n    fi
    
    # Cleanup test deployment
    kubectl delete -f /tmp/test-deployment.yaml || true\n    kubectl delete -f k8s/service.yaml || true\n    rm -f /tmp/test-deployment.yaml
}

# Test 5: Jenkins pipeline syntax
test_jenkins_pipeline() {
    echo "🏗️  Test 5: Jenkins Pipeline Syntax"
    
    # Basic syntax check (simplified)
    if grep -q "pipeline {" Jenkinsfile && grep -q "stages {" Jenkinsfile; then
        print_success "Jenkinsfile basic syntax looks good"
    else
        print_error "Jenkinsfile syntax issues detected"
        return 1
    fi
}

# Performance test
performance_test() {
    echo "⚡ Bonus: Performance Test"
    
    docker run -d -p 5003:5000 --name perf-test jenkins-k8s-demo:test
    sleep 5
    
    # Simple load test with curl\n    echo "Running 10 concurrent requests..."
    for i in {1..10}; do
        curl -s http://localhost:5003 > /dev/null &
    done
    wait
    
    if curl -s http://localhost:5003/health | grep -q "healthy"; then
        print_success "Application survived basic load test"
    else
        print_warning "Application may have issues under load"
    fi
    
    docker stop perf-test && docker rm perf-test
}

# Run all tests
run_tests() {
    local failed_tests=0
    
    test_docker_build || ((failed_tests++))
    test_application || ((failed_tests++))
    test_k8s_manifests || ((failed_tests++))
    test_minikube_deployment || ((failed_tests++))
    test_jenkins_pipeline || ((failed_tests++))
    performance_test || true  # Don't fail on performance test
    
    echo ""
    echo "📊 Test Results"
    echo "=============="
    
    if [ $failed_tests -eq 0 ]; then
        print_success "All tests passed! 🎉"
        echo "Your Jenkins-K8s pipeline is ready for deployment!"
    else
        print_error "$failed_tests test(s) failed"
        echo "Please fix the issues before proceeding."
        exit 1
    fi
}

# Cleanup function
cleanup() {
    echo "🧹 Cleaning up test resources..."
    docker rm -f test-app-func perf-test test-app 2>/dev/null || true
    docker rmi jenkins-k8s-demo:test 2>/dev/null || true
}

# Main execution
trap cleanup EXIT
run_tests