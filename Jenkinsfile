pipeline {
    agent {node {label 'linux'}}
   def app = ''
   
   stages {
       stage('pull code') {  
          git 'https://github.com/Adarbe/finalapp.git'
       }
        
    stage('Docker build ') {
        app = docker.build("[https://github.com/Adarbe/finalapp/blob/master/Dockerfile-app]" , "--tag {adarbe/final-project:${BUILD_NUMBER}}")
        withDockerRegistry(credentialsId: 'dockerhub.adarbe') {
        app.push()
        }
       }

     stage('Apply Kubernetes files') {
         withAWS(region: 'us-east-1', credentials: "jenkins" ) {
           sh """
           aws eks update-kubeconfig --name "final-project-eks-${random_string.suffix.result}"
           sed -i "s?IMAGE_PLA?adarbe/final-project:${repo.GIT_COMMIT}_${BUILD_NUMBER}?" deployment.yml
           kubectl apply -f deployment.yml
           """
          }
       }
      }
    }
  
