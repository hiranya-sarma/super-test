# Super-Project
This is major Project

## Pipeline scripts:

### servers using terraform
```
pipeline {
    agent any
    environment{
        creds = credentials('aws-key')
    }
    stages {
        stage('checkout stage'){
            steps{
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/hiranya-sarma/super-test.git']])
            }
        }
        stage('terraform init'){
            steps{
                sh 'terraform init'
            }
        }
        stage('terraform plan'){
            steps{
                sh 'terraform plan'
            }
        }
        stage('terraform apply'){
            steps{
                sh 'terraform apply -auto-approve'
            }
        }
    }
}
```
### test-ansible

```
pipeline {
    agent any
     environment{
        privatekey = credentials('ansiblekey')
    }
    stages {
        stage('checkout stage') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/hiranya-sarma/super-test.git']])
           }
        }
        stage('ansible test'){
            steps{
                sh "ansible all -i inventory -m ping --private-key ${privatekey}" 
                sh "ansible-playbook -i inventory --private-key ${privatekey} playbook.yaml"
            }
        }
    
    }
}
```
### version-test
```
pipeline {
    agent any

    stages {
        stage('git version') {
            steps {
                sh 'git version'
            }
        }
        stage('docker version') {
            steps {
                sh 'docker version'
            }
        }
        stage('ansible version') {
            steps {
                sh 'ansible --version'
            }
        }
        stage('terraform version') {
            steps {
                sh 'terraform version'
            }
        }
        stage('eksctl/kubectl version') {
            steps {
                sh 'eksctl version'
                sh 'kubectl version --client'
            }
        }
    }
}
```
## super-project
### This is our super-project main pipeline.
```
pipeline {
    agent any
    environment{
        cred = credentials('aws-key')
    }
    options {
        buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '30', numToKeepStr: '5')
        timeout(30)
    }
    tools{
        maven 'Maven'
    }

    stages {
         stage('checkout stage'){
            steps{
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/hiranya-sarma/super-test.git']])
            }
          }
         stage('SonarQube Analysis') {
              steps{
                  script{
                      def mvn = tool 'Maven';
                      withSonarQubeEnv(installationName: 'sonarqube-server') {
                      sh "${mvn}/bin/mvn clean verify sonar:sonar -Dsonar.projectKey=superproject"
                     }
                  }
              }
            }
         stage('maven build'){
            steps{
                sh 'mvn package'
            }
         }
         stage('nexus test'){
            steps{
                nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    nexusUrl: '52.200.240.191:8081',
                    groupId: 'addressbook',
                    version: '2.0-SNAPSHOT',
                    repository: 'maven-snapshots',
                    credentialsId: 'nexus',
                    artifacts: [
                        [artifactId: 'SuperProject',
                        classifier: '',
                        file: 'target/addressbook-2.0.war',
                        type: 'war']
                     ]
                )
            }
        }
         stage('Docker build'){
                steps{
                    sh 'docker build -t super-project .'
                }
            }
         stage('DockerHub push'){
            steps{
                sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 367757174440.dkr.ecr.us-east-1.amazonaws.com'
                sh "docker tag super-project:latest 367757174440.dkr.ecr.us-east-1.amazonaws.com/super-project:latest"
                sh "docker push 367757174440.dkr.ecr.us-east-1.amazonaws.com/super-project:latest"
                sh "docker tag super-project:latest 367757174440.dkr.ecr.us-east-1.amazonaws.com/super-project:${BUILD_NUMBER}"
                sh "docker push 367757174440.dkr.ecr.us-east-1.amazonaws.com/super-project:${BUILD_NUMBER}"
                
            }
        } 
         stage('Kubernetes deploy'){
            steps{
                sh 'aws eks update-kubeconfig --region us-east-1 --name super-project'
                sh 'kubectl apply -f Application.yaml'
            }
        }
         }
    post {
        always {
            echo "Job is completed"
        }
        success {
            echo "success"
        }
        failure {
            echo "failed"
        }
    }     
   }
```
### Inside jenkins EC2 below commands need to run
```
[ec2-user@ip-172-31-42-80 ~]$ history
    1  vi jenkinsscript.sh
    2  sh jenkinsscript.sh 
    3  #!/bin/bash
    4  sudo yum install -y yum-utils shadow-utils
    5  sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    6  sudo yum -y install terraform
    7  terraform version
    8  sudo yum install git -y
    9  git version
   10  sudo yum install docker -y
   11  sudo systemctl enable docker.service
   12  sudo systemctl start docker.service
   13  docker ps
   14  sudo chmod 777 /var/run/docker.sock
   15  docker ps
   16  sudo yum install ansible -y
   17  ansible --version
   18  # for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
   19  ARCH=amd64
   20  PLATFORM=$(uname -s)_$ARCH
   21  curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
   22  # (Optional) Verify checksum
   23  curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check
   24  tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
   25  sudo install -m 0755 /tmp/eksctl /usr/local/bin && rm /tmp/eksctl
   26  eksctl --version
   27  eksctl version
   28  curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.3/2025-08-03/bin/linux/amd64/kubectl
   29  curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.3/2025-08-03/bin/linux/amd64/kubectl.sha256
   30  sha256sum -c kubectl.sha256
   31  openssl sha1 -sha256 kubectl
   32  chmod +x ./kubectl
   33  mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
   34  echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
   35  ls
   36  sudo mv /usr/local/bin/
   37  sudo mv kubectl /usr/local/bin/
   38  kubectl version --client
   39  aws configure
   40  vi cluster-trust-policy.json
   41  aws iam create-role   --role-name eksClusterRole   --assume-role-policy-document file://"cluster-trust-policy.json"
   42  aws iam attach-role-policy   --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy   --role-name eksClusterRole
   43  cat ~/.bash_history
   44  history
```
