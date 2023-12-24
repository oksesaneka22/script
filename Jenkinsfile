pipeline {
    agent any

    stages {
        stage('Hello') {
            steps {
                script {
                    // Use 'sh' step to execute shell commands
                    sh 'ls /'
                    sh 'docker login -u oksesaneka22 -p password docker.io'
                    sh 'docker build . --tag oksesaneka22/ansible:latest'
                    sh 'docker push oksesaneka22/ansible:latest'
                }
            }
        }
    }
}
