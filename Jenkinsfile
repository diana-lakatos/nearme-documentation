pipeline {
    agent any

    stages {

        stage('Build') {
            steps {
                checkout scm

                sh "gem install yard --no-ri --no-rdoc && \
                    export RUBY_THREAD_VM_STACK_SIZE=5000000 && \
                    yard -e lib/yard_frontend_customizations.rb -p .yard/frontend_template/ --hide-tag todo --markup markdown 'lib/liquid/**/*.rb' 'app/liquid_tags/*.rb' 'app/forms/**/*.rb'"
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
