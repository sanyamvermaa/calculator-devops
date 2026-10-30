pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'sanyamvermaa'
        IMAGE_NAME     = "${DOCKERHUB_USER}/calculator-devops"
        IMAGE_TAG      = "${env.BUILD_NUMBER}"
        FULL_IMAGE     = "${IMAGE_NAME}:${IMAGE_TAG}"
        NOTIFY_EMAIL   = 'svm11681@gmail.com'
    }

    options {
        timestamps()                                  // every log line gets a timestamp
        timeout(time: 20, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '15'))
        disableConcurrentBuilds()                     // webhook and Poll SCM can fire for the
                                                      // same commit; queue instead of racing
                                                      // over the 'calculator' container name
    }

    stages {

        stage('1. Checkout') {
            steps {
                checkout scm
                sh 'git log -1 --oneline'
            }
        }

        stage('2. Build') {
            steps {
                sh './mvnw -B -ntp clean package -DskipTests'
            }
        }

        stage('3. Test') {
            steps {
                sh './mvnw -B -ntp test'
            }
            post {
                always {
                    // Publish JUnit XML even when tests fail — this draws the trend graph
                    junit testResults: 'target/surefire-reports/*.xml',
                          allowEmptyResults: false
                }
            }
        }

        stage('4. Docker Build') {
            steps {
                sh 'docker build -t "$IMAGE_NAME:$IMAGE_TAG" -t "$IMAGE_NAME:latest" .'
                sh 'docker images "$IMAGE_NAME"'
            }
        }

        stage('5. Push') {
            steps {
                withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DH_USER',
                        passwordVariable: 'DH_PASS')]) {
                    sh '''
                        echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
                        docker push "$IMAGE_NAME:$IMAGE_TAG"
                        docker push "$IMAGE_NAME:latest"
                        docker logout
                    '''
                }
            }
        }

        stage('6. Deploy') {
            steps {
                // Give compose the exact tag we just pushed.
                // 'up -d' (never 'down') keeps the re-run idempotent with no downtime.
                sh '''
                    export DOCKER_IMAGE="$IMAGE_NAME:$IMAGE_TAG"
                    echo "Deploying $DOCKER_IMAGE ..."
                    docker compose pull
                    docker compose up -d --remove-orphans

                    # Poll until healthy rather than a blind sleep
                    for i in $(seq 1 24); do
                        if curl -fsS http://localhost/actuator/health | grep -q '"status":"UP"'; then
                            echo "Healthy after ${i} attempt(s)"
                            docker compose ps
                            exit 0
                        fi
                        sleep 5
                    done
                    echo "Not healthy after 2 minutes"
                    docker compose ps
                    docker compose logs --tail=100
                    exit 1
                '''
            }
        }
    }

    post {
        success {
            emailext(
                subject: "[Jenkins] SUCCESS: ${JOB_NAME} #${BUILD_NUMBER}",
                body: """
                    <h2 style="color:#2E8B57">Build succeeded</h2>
                    <ul>
                      <li><b>Job:</b> ${JOB_NAME}</li>
                      <li><b>Build:</b> #${BUILD_NUMBER}</li>
                      <li><b>Image:</b> ${FULL_IMAGE}</li>
                      <li><b>URL:</b> <a href="${BUILD_URL}">${BUILD_URL}</a></li>
                    </ul>
                """,
                to: "${NOTIFY_EMAIL}",
                mimeType: 'text/html'
            )
        }
        failure {
            emailext(
                subject: "[Jenkins] FAILED: ${JOB_NAME} #${BUILD_NUMBER}",
                body: """
                    <h2 style="color:#B23A48">Build failed</h2>
                    <ul>
                      <li><b>Job:</b> ${JOB_NAME}</li>
                      <li><b>Build:</b> #${BUILD_NUMBER}</li>
                      <li><b>Console:</b> <a href="${BUILD_URL}console">${BUILD_URL}console</a></li>
                    </ul>
                """,
                to: "${NOTIFY_EMAIL}",
                mimeType: 'text/html'
            )
        }
        always {
            // Wipe stale images from the Jenkins agent so disk doesn't fill up
            sh 'docker image prune -f --filter "until=72h" || true'
        }
    }
}
