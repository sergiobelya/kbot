pipeline {
    agent any

    parameters {
        choice(name: 'OS', choices: ['linux', 'darwin', 'windows'], description: 'Pick OS')
        choice(name: 'ARCH', choices: ['amd64', 'arm64'], description: 'Pick ARCH')
    }

    environment {
        REPO = 'https://github.com/sergiobelya/kbot'
        BRANCH = 'main'
    }

    stages {
        stage('Example') {
            steps {
                echo "Build for platform ${params.OS}"
                echo "Build for arch: ${params.ARCH}"
            }
        }
        stage('clone') {
            steps {
                echo 'Clone Repository'
                git branch: "${BRANCH}", url: "${REPO}"
            }
        }
    }
}