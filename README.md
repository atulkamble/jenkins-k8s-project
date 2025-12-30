## 🚀 Project: Jenkins CI/CD Pipeline → Kubernetes Deployment

### 🎯 What You’ll Build

* Jenkins Pipeline (Declarative)
* Docker image build & push
* Kubernetes deployment using `kubectl`
* End-to-end CI/CD automation

---

## 🧩 Architecture Overview

![Image](https://dz2cdn1.dzone.com/storage/temp/11003693-screenshot-2019-01-05-140134.png)

![Image](https://miro.medium.com/0%2AdZsiK1TUZuq8xImf.jpeg)

![Image](https://platform9.com/media/kubernetes-constructs-concepts-architecture.jpg)

**Flow:**

```
GitHub → Jenkins → Docker Hub → Kubernetes Cluster
```

---

## 📁 Project Repository Structure

```
jenkins-k8s-cicd-project/
│
├── app/
│   ├── app.py
│   └── requirements.txt
│
├── Dockerfile
├── Jenkinsfile
│
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
│
└── README.md
```

---

## 🛠️ Prerequisites

| Tool       | Purpose                 |
| ---------- | ----------------------- |
| Jenkins    | CI/CD engine            |
| Docker     | Image build             |
| Kubernetes | Container orchestration |
| kubectl    | K8s CLI                 |
| GitHub     | Source control          |
| Docker Hub | Image registry          |

---

## 🔹 Step 1: Sample Application (Python Flask)

### `app/app.py`

```python
from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return "🚀 Jenkins + Kubernetes CI/CD Working!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

### `app/requirements.txt`

```
flask
```

---

## 🔹 Step 2: Dockerfile

```dockerfile
FROM python:3.10-slim

WORKDIR /app

COPY app/requirements.txt .
RUN pip install -r requirements.txt

COPY app/ .

EXPOSE 5000

CMD ["python", "app.py"]
```

---

## 🔹 Step 3: Kubernetes Manifests

### `k8s/deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: flask
  template:
    metadata:
      labels:
        app: flask
    spec:
      containers:
      - name: flask
        image: DOCKERHUB_USERNAME/flask-cicd:latest
        ports:
        - containerPort: 5000
```

### `k8s/service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: flask-service
spec:
  type: NodePort
  selector:
    app: flask
  ports:
    - port: 80
      targetPort: 5000
      nodePort: 30007
```

---

## 🔹 Step 4: Jenkins Pipeline (Heart of Project)

### `Jenkinsfile`

```groovy
pipeline {
    agent any

    environment {
        IMAGE_NAME = "flask-cicd"
        DOCKERHUB_USER = "your_dockerhub_username"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git 'https://github.com/yourusername/jenkins-k8s-cicd-project.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t $DOCKERHUB_USER/$IMAGE_NAME:latest ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([string(credentialsId: 'dockerhub-pass', variable: 'PASS')]) {
                    sh """
                    echo $PASS | docker login -u $DOCKERHUB_USER --password-stdin
                    docker push $DOCKERHUB_USER/$IMAGE_NAME:latest
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                kubectl apply -f k8s/deployment.yaml
                kubectl apply -f k8s/service.yaml
                """
            }
        }
    }
}
```

---

## 🔐 Jenkins Credentials Setup

| Credential       | Type                     |
| ---------------- | ------------------------ |
| `dockerhub-pass` | Secret Text              |
| Kubeconfig       | Stored on Jenkins server |

---

## 🔹 Step 5: Kubernetes Access (One-Time)

```bash
kubectl get nodes
kubectl get pods
```

Ensure Jenkins user has:

```
~/.kube/config
```

---

## 🔍 Verification

```bash
kubectl get deployments
kubectl get svc
```

Access App:

```
http://<NODE-IP>:30007
```

✅ Output:

```
🚀 Jenkins + Kubernetes CI/CD Working!
```

---

## 🧠 Interview Talking Points

* Jenkins Declarative Pipeline
* Docker image lifecycle
* Kubernetes Deployment vs Service
* CI/CD automation benefits
* Zero-downtime rolling updates

---

## 📦 Enhancements (Advanced)

✔ Helm Charts
✔ Blue-Green Deployment
✔ ArgoCD (GitOps)
✔ Ingress + TLS
✔ Prometheus Monitoring

---

## 🧾 README.md (Short)

```md
# Jenkins Kubernetes CI/CD Project
End-to-end CI/CD pipeline using Jenkins, Docker, and Kubernetes.
```

---
