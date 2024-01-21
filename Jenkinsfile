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
        stage('UP ZABBIX and PUSH') {
            steps {
                script {
                    // Use 'sh' step to execute shell commands
                    sh 'pwd'
                    sh 'docker-compose -f compose.yml up -d'
                    sh 'docker commit zabbix-postgres oksesaneka22/zabbix:zabbix-postgres'
                    sh 'docker commit zabbix-server oksesaneka22/zabbix:zabbix-server'
                    sh 'docker commit zabbix-web oksesaneka22/zabbix:zabbix-web'
                    sh 'docker push oksesaneka22/zabbix:zabbix-postgres'
                    sh 'docker push oksesaneka22/zabbix:zabbix-server'
                    sh 'docker push oksesaneka22/zabbix:zabbix-web'
                }
            }
        }
        stage('DOWNLOAD AND SET UP ZABBIX') {
            steps {
                script {
                    // Use 'sh' step to execute shell commands
                    sh 'rm docker-compose.yaml'
                    sh 'touch docker-compose.yaml'
                    sh 'cat >> docker-compose.yaml
                    version: "3"
                    services:
                      zabbix-postgress:
                        image: oksesaneka22/zabbix:zabbix-postgres
                        container_name: zabbix-postgres
                        networks:
                          - zabbix-net
                        volumes:
                          - ./data:/var/lib/postgresql/data
                          - ./var/lib/zabbix/timezone:/etc/timezone:ro
                          - ./var/lib/zabbix/localtime:/etc/localtime:ro
                        environment:
                          - POSTGRES_USER=zabbix
                          - POSTGRES_PASSWORD=zabbix
                      zabbix-server:
                        image: oksesaneka22/zabbix:zabbix-server
                        container_name: zabbix-server
                        networks:
                          - zabbix-net
                        volumes:
                          - /var/lib/zabbix/alertscripts:/usr/lib/zabbix/alertscripts
                          - /var/lib/zabbix/timezone:/etc/timezone:ro
                          - /var/lib/zabbix/localtime:/etc/localtime:ro
                        ports:
                          - "10051:10051"
                          - "161:161"
                        environment:
                          - DB_SERVER_HOST=zabbix-postgres
                          - POSTGRES_USER=zabbix
                          - POSTGRES_PASSWORD=zabbix
                      zabbix-web:
                        image: oksesaneka22/zabbix:zabbix-web
                        container_name: zabbix-web
                        networks:
                          - zabbix-net
                        volumes:
                          - ./var/lib/zabbix/timezone:/etc/timezone:ro
                          - ./var/lib/zabbix/localtime:/etc/localtime:ro
                        ports:
                          - "80:8080"
                          - "443:8443"
                        environment:
                          - DB_SERVER_HOST=zabbix-postgres
                          - POSTGRES_USER=zabbix
                          - POSTGRES_PASSWORD=zabbix
                          - ZBX_SERVER_HOST=zabbix-server
                          - PHP_TZ=Europe/Kiev
                    networks:
                      zabbix-net:
                        driver: bridge'
                    sh 'docker-compose -f docker-compose.yaml up -d'
                }
            }
        }
    }
}
