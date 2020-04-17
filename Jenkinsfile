
node {
  def app = ""
    stage("pull code") {
	      repo = git https://github.com/muhammadhanif/crud-application-using-flask-and-mysql.git
    }
    stage('Docker build ') {
	    app = docker.build("adarbe/final-project:${repo.GIT_COMMIT}_${BUILD_NUMBER}")
	    withDockerRegistry(credentialsId:'dockerhub.adarbe') {
        app.push()
		}
    }
}
   
