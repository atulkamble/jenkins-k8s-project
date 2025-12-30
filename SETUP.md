# Jenkins-K8s Project - Local Development Guide

## 📋 Prerequisites

Before running this project, ensure you have the following installed:

### Required Tools:
- **Docker**: For containerization
- **Docker Compose**: For local Jenkins setup
- **kubectl**: Kubernetes CLI
- **Minikube**: Local Kubernetes cluster
- **Git**: Version control

### Installation Commands (macOS):

```bash
# Install Docker Desktop (includes Docker Compose)
# Download from: https://www.docker.com/products/docker-desktop

# Install kubectl
brew install kubectl

# Install Minikube
brew install minikube

# Verify installations
docker --version
kubectl version --client
minikube version
```

## 🚀 Quick Start

### 1. Clone and Setup
```bash
git clone <your-repo-url>
cd jenkins-k8s-project

# Make scripts executable
chmod +x setup.sh test.sh

# Run the setup script
./setup.sh
```

### 2. Manual Setup (Alternative)

#### Start Minikube:
```bash
minikube start --driver=docker --cpus=2 --memory=4096
minikube addons enable ingress
```

#### Start Jenkins:
```bash
docker-compose up -d jenkins

# Wait for Jenkins to start (about 1-2 minutes)
# Get initial admin password:
docker exec jenkins-local cat /var/jenkins_home/secrets/initialAdminPassword
```

#### Build and Test Application:
```bash
# Build Docker image
docker build -t jenkins-k8s-demo:local .

# Test locally
docker run -p 5000:5000 jenkins-k8s-demo:local
```

#### Deploy to Minikube:
```bash
# Load image to Minikube
minikube image load jenkins-k8s-demo:local

# Update deployment.yaml to use local image
sed -i 's|your-dockerhub-username/jenkins-k8s-demo:latest|jenkins-k8s-demo:local|g' k8s/deployment.yaml

# Deploy to Kubernetes
kubectl apply -f k8s/

# Check deployment status
kubectl rollout status deployment/jenkins-k8s-demo

# Access the application
minikube service jenkins-k8s-demo-nodeport --url
```

## 🧪 Testing

Run the comprehensive test suite:
```bash
./test.sh
```

This will test:
- Docker build process
- Application functionality
- Kubernetes manifest validation
- Minikube deployment
- Jenkins pipeline syntax

## 🏗️ Jenkins Configuration

### 1. Initial Setup
1. Access Jenkins at `http://localhost:8080`
2. Use the initial admin password from: `docker exec jenkins-local cat /var/jenkins_home/secrets/initialAdminPassword`
3. Install suggested plugins
4. Create an admin user

### 2. Configure Required Plugins
Install these plugins via Jenkins Plugin Manager:
- **Docker Pipeline**
- **Kubernetes CLI**
- **Pipeline**
- **Git**

### 3. Configure Credentials
Add these credentials in Jenkins (Manage Jenkins → Manage Credentials):

#### Docker Hub Credentials:
- ID: `docker-hub-credentials`
- Type: Username with password
- Username: Your Docker Hub username
- Password: Your Docker Hub password/token

#### Kubeconfig:
- ID: `kubeconfig` 
- Type: Secret file
- File: Upload your `~/.kube/config`

### 4. Create Pipeline Job
1. New Item → Pipeline
2. Pipeline Definition: Pipeline script from SCM
3. SCM: Git
4. Repository URL: Your repository URL
5. Script Path: `Jenkinsfile`

## 🔧 Customization

### Update Docker Hub Repository
Edit the `Jenkinsfile` and update:
```groovy
DOCKER_HUB_REPO = 'your-actual-dockerhub-username/jenkins-k8s-demo'
```

### Modify Application
The Flask app is in `app/app.py`. Make changes and rebuild:
```bash
docker build -t jenkins-k8s-demo:local .
minikube image load jenkins-k8s-demo:local
kubectl rollout restart deployment/jenkins-k8s-demo
```

### Kubernetes Configuration
Modify `k8s/deployment.yaml` and `k8s/service.yaml` as needed:
- Change replica count
- Update resource limits
- Modify service type (NodePort/LoadBalancer)

## 🌐 Access URLs

| Service | URL | Notes |
|---------|-----|-------|
| Jenkins | http://localhost:8080 | Admin interface |
| App (local) | http://localhost:5000 | Direct Docker run |
| App (K8s) | `minikube service jenkins-k8s-demo-nodeport --url` | Via Minikube |
| Minikube Dashboard | `minikube dashboard` | K8s web interface |

## 🛠️ Useful Commands

### Docker Commands:
```bash
docker ps                              # List running containers
docker logs jenkins-local              # View Jenkins logs
docker exec -it jenkins-local bash     # Shell into Jenkins container
```

### Kubernetes Commands:
```bash
kubectl get pods                       # List pods
kubectl get services                   # List services
kubectl logs <pod-name>               # View pod logs
kubectl describe pod <pod-name>       # Pod details
kubectl delete -f k8s/                # Delete all resources
```

### Minikube Commands:
```bash
minikube status                        # Check status
minikube stop                          # Stop cluster
minikube delete                        # Delete cluster
minikube ip                           # Get cluster IP
minikube service list                 # List services
```

## 🐛 Troubleshooting

### Common Issues:

#### Jenkins not starting:
```bash
docker-compose logs jenkins
# Check if port 8080 is already in use
lsof -i :8080
```

#### Minikube issues:
```bash
minikube delete
minikube start --driver=docker
```

#### Image not found in Minikube:
```bash
# Make sure to load the image
minikube image load jenkins-k8s-demo:local
# Or build directly in Minikube
eval $(minikube docker-env)
docker build -t jenkins-k8s-demo:local .
```

#### kubectl connection issues:
```bash
kubectl config current-context
kubectl config use-context minikube
```

## 📚 Next Steps

1. **Set up automated testing** in the Jenkins pipeline
2. **Add monitoring** with Prometheus/Grafana
3. **Implement GitOps** with ArgoCD
4. **Add security scanning** with tools like Trivy
5. **Set up production deployment** to cloud K8s clusters

## 🎯 Learning Objectives

By completing this project, you'll learn:
- ✅ Docker containerization
- ✅ Jenkins CI/CD pipeline creation
- ✅ Kubernetes deployment and management
- ✅ Local development with Minikube
- ✅ Infrastructure as Code practices
- ✅ DevOps automation workflows