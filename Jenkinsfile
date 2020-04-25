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
    stage("deploy app") {
                sh "aws eks --region us-east-1 update-kubeconfig --name final-project-eks"
                sh "chmod +x ./*"
                sh "chmod +x ./*/*"
                sh "chmod +x ./*/*/*"
                sh "kubectl apply -f ./services.yaml"
                sh "kubectl apply -f ./deployment.yaml"
    }
}
