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

