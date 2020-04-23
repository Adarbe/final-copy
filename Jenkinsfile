node('linux') { 
 def Dockerfile = "Dockerfile-app"
 def app = ''
 
    stage('pull code') {
       git branch: 'master',
       url: "https://github.com/Adarbe/finalapp.git"
    }
       
    stage('Docker build ') {
     script {
      app = docker.build ["-t {"adarbe/final-project:${BUILD_NUMBER}"], ["-f ${Dockerfile} ."]
        withDockerRegistry(credentialsId: 'dockerhub.adarbe') {
        app.push()
        }
      }
    }
  }

