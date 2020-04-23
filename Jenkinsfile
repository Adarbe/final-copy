node('linux') { 
 def app = ''
 
    stage('pull code') {
       repo = git 'https://github.com/adarbe/finalapp.git'
    }
       
    stage('Docker build ') {
        app = docker.build("[https://github.com/adarbe/finalapp/blob/master/dockerfile-app]" , "-t adarbe/final-project:${BUILD_NUMBER}")
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
