ipeline {
   agent node('linux')
   def app = ''
   
   stages {
       stage('pull code') {  
          git 'https://github.com/Adarbe/finalapp.git'
       }
        
       stage('Docker build ') {
          def app = docker.build [https://github.com/Adarbe/finalapp/blob/master/Dockerfile-app] -t "adarbe/final-project:${BUILD_NUMBER}"
        }      


        stage('Push to Dockerhub') {
          script {
            docker.withDockerRegistry(credentialsId: 'dockerhub.adarbe') {
              app.push()
            }
          } 
        }
      }
    }
