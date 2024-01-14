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
                    sh 'pwd'
                    sh 'wget https://oksesaneka22.github.io/script/compose.yml && docker-compose -f compose.yml up -d'
                    sh 'docker commit zabbix-postgres'
                    sh 'docker commit zabbix-server'
                    sh 'docker commit zabbix-web'
                    sh 'docker tag zabbix-postgres oksesaneka22/zabbix:zabbix-postgres'
                    sh 'docker tag zabbix-server oksesaneka22/zabbix:zabbix-server'
                    sh 'docker tag zabbix-web oksesaneka22/zabbix:zabbix-web'
                    sh 'docker push oksesaneka22/zabbix:zabbix-postgres'
                    sh 'docker push oksesaneka22/zabbix:zabbix-server'
                    sh 'docker push oksesaneka22/zabbix:zabbix-web'
                }
            }
        }
    }
}
