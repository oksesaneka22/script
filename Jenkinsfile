pipeline {
    agent any

    stages {
        stage('Hello') {
            steps {
                script {
                    // Use 'sh' step to execute shell commands
                    sh 'ls /'
                    sh 'apt install mc -y'
                    sh 'docker run -d -p 8081:80 oksesaneka22/nginx:nice'
                }
            }
        }
    }
}
