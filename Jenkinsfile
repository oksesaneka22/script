pipeline {
    agent any

    stages {
        stage('Hello') {
            steps {
                script {
                    // Use 'sh' step to execute shell commands
                    sh 'ls /'
                    sh 'docker login -u oksesaneka22 -p saneka22 docker.io'
                    sh 'cd /home/ubuntu/docker/ansible/'
                    sh 'docker build . --tag oksesaneka22/ansible:latest'
                    sh 'docker push oksesaneka22/ansible:latest'
                }
            }
        }
    }
}
