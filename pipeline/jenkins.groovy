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
        stage('Show params') {
            steps {
                echo "Platform: ${params.OS}"
                echo "Arch: ${params.ARCH}"
            }
        }
        stage('clone') {
            steps {
                echo 'Clone Repository'
                git branch: "${BRANCH}", url: "${REPO}"
            }
        }
        stage('test') {
            steps {
                echo 'Run tests'
                sh "make test"
            }
        }
        stage('build') {
            steps {
                echo "Build application for platform: ${params.OS}, architecture: ${params.ARCH}"
                sh "make TARGETOS=${params.OS} TARGETARCH=${params.ARCH} build"
            }
        }
    }
}