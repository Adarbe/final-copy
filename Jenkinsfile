node('linux') { 
    def app = ''
    def Dockerfile = 'Dockerfile-app'
 
    stage('pull code') {
      git 'https://github.com/Adarbe/finalapp.git'
    }

    stage('Docker build ') {
      script {
        app = docker.build'adarbe/final-project:${BUILD_NUMBER}'  "-f ${Dockerfile} ." 
      }
    }

    stage('Push to Dockerhub') {
      script {
        docker.withDockerRegistry(credentialsId: 'dockerhub.adarbe') {
          app.push()
        }
      } 
    }
  
    stage('Apply Kubernetes files') {
        withAWS(region: 'us-east-1', credentials: "jenkins" ) {
          sh ''
          aws eks update-kubeconfig --name 'final-project-eks-${random_string.suffix.result}'
          kubectl apply -f deployment.yml
          ''
        }
    }
}

