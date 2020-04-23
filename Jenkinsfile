node('linux') { 
 def app = ''
 
    stage('pull code') {
       git branch: 'master',
       url: "github.com/Adarbe/finalapp/Dockerfile-app"
    }
       
    stage('Docker build ') {
     script {
      app = docker.build("https://github.com/adarbe/finalapp/blob/master/Dockerfile-app", "-t {adarbe/final-project:${BUILD_NUMBER}}")
        withDockerRegistry(credentialsId: 'dockerhub.adarbe') {
        app.push()
        }
      }
    }
  }

