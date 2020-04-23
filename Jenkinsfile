
node('linux') { 
 def app = ''
    stage('pull code') {
       git branch: 'master',
       url: "https://github.com/Adarbe/finalapp.git"
    }
       
    stage('Docker build') {
     script {
      app = docker build ("adarbe/final-project:${BUILD_NUMBER}" "-f https://github.com/Adarbe/finalapp.git/Dockerfile-app") 
      }
    }
    
    stage('deployment'){
      steps{
        script{
          docker.withDockerRegistry(credentialsId: 'dockerhub.adarbe'){
          app.push()
        }
      }
    }  
  }
}
