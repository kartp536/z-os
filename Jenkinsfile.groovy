pipeline {
        agent any
        stages {
            stage('Script-01') {
                steps {
                    script {
                            build job: 'Script-01'
                        }
                    }
               }   
            stage('Script-02') {
                steps {
                    script {
                            build job: 'Script-02'
                        }
                    }
               }   
           }
       }
