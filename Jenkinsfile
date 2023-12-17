pipeline {
    agent any

    stages {
        stage('Hello') {
            steps {
                script {
                    // Use 'sh' step to execute shell commands
                    sh 'ls /'
                    sh 'sudo apt install apache2 -S ubuntu'
                }
            }
        }
    }
}
