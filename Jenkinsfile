pipeline {
    agent any

    stages {

        stage('Build') {
            steps {
                checkout scm
                sh "docker-compose -f ci/docker-compose.yml build"
            }
        }

        stage('Deploy documentation to gh') {
            steps {
                withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'MyID', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD']]) {
                    sh "git checkout -b jenkins"
                    sh("git tag -a 0.0.0.1 -m 'Jenkins'")
                    sh('git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/mdyd-dev/nearme-documentation.git --tags')
                }
                echo 'Done'
            }
        }
    }
}
