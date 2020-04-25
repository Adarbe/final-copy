node('linux') {
checkout scm
def dockerfile = "Dockerfile-app"
def app = ''
 
    stage('pull code') {
       git branch: 'master',
       url: "https://github.com/Adarbe/finalapp.git"
    }
       
    stage('Docker build ') {
     script {
      app = docker.build ("adarbe/final-project:${BUILD_NUMBER}", "-f ${dockerfile} https://github.com/Adarbe/finalapp.git")  
      }
    }
    
    stage('deployment'){
        script{
          docker.withRegistry("https://registry.hub.docker.com" ,"dockerhub.adarbe"){
          app.push()
        }
      }  
  }
    stage('Apply Kubernetes files') {
       withAWS(region: us-east-1, role: final-jenkins_eks, roleAccount: '555478048938')
          sh """
          aws eks update-kubeconfig --name "final-project-eks-${suffix.result}"
          sed -i "s?IMAGE_PLA?adarbe/final-project:${BUILD_NUMBER}?" 
          kubectl apply -f deployment.yml
          """
        }
    }
} 
