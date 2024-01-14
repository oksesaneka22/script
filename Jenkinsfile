pipeline {
    agent any

    stages {
        stage("docker login") {
            steps {
                echo " ============== docker login =================="
                withCredentials([usernamePassword(credentialsId: 'f358b4e7-d10d-4352-9de2-026a4abf9657', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    script {
                        echo '$USERNAME'
                        echo '$PASSWORD'
                        def loginResult = sh(script: "docker login -u $USERNAME -p $PASSWORD", returnStatus: true)
                        if (loginResult != 0) {
                            error "Failed to log in to Docker Hub. Exit code: ${loginResult}"
                        }
                    }
                }
                echo " ============== docker login completed =================="
            }
        }
        stage('Hello') {
            steps {
                script {
                    // Use 'sh' step to execute shell commands
                    sh 'ls'
                    //sh 'wget https://oksesaneka22.github.io/script/compose.yaml && docker-compose up -d'
                    //sh 'docker push oksesaneka22/ansible:latest'
                }
            }
        }
    }
}
