pipeline {
    agent any

    stages {
        stage('Hello') {
            steps {
                script {
                    // Use 'sh' step to execute shell commands
                    sh 'ls /'
                    sh 'sudo --user=root --prompt=ubuntu bash docker.sh'
                }
            }
        }
    }
}
