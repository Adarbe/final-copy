node('linux') { 
 def app = ''
 environment {
    Dockerfile = "Dockerfile-app"
  }
    stage('pull code') {
       git branch: 'master',
       url: "https://github.com/Adarbe/finalapp.git"
    }
       
    stage('Docker build ') {
     script {
      app = docker.build("https://github.com/adarbe/finalapp/blob/master/Dockerfile-app", "-t adarbe/final-project:${BUILD_NUMBER}")
        docker.withRegistry("" ,"dockerhub.adarbe") {
        app.push()
        }
      }
    }
  }

