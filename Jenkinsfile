node('linux') { 
 def app = ''
 
    stage('pull code') {
       repo = git 'https://github.com/adarbe/finalapp.git'
    }
       
    stage('Docker build ') {
        app = docker.build(["https://github.com/adarbe/finalapp/blob/master/Dockerfile-app", "-t adarbe/final-project:${BUILD_NUMBER}"])
        withDockerRegistry(credentialsId: 'dockerhub.adarbe') {
        app.push()
        }
      }
  }

