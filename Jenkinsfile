#!groovy

// pod utilisé pour la compilation du projet
podTemplate(label: 'chart-run-pod', containers: [

        // le slave jenkins
        containerTemplate(name: 'jnlp', image: 'jenkinsci/jnlp-slave:alpine'),

        containerTemplate(name: 'helm', image: 'elkouhen/k8s-helm:2.9.1c', ttyEnabled: true, command: 'cat')],

        // montage nécessaire pour que le conteneur docker fonction (Docker In Docker)
        volumes: [hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock')]
) {

    node('chart-run-pod') {

        properties([
                parameters([
                        string(defaultValue: 'latest', description: 'Version à déployer', name: 'image'),
                        string(defaultValue: '', description: 'Nom du chart à deployer', name: 'chart'),
                        string(defaultValue: 'dev', description: 'Environnement de déploiement', name: 'env')
                ])
        ])

        stage('CHECKOUT') {
            checkout scm;
        }

        container('helm') {

            stage('helm deploy') {

                withCredentials([string(credentialsId: 'pgp_helm_pwd', variable: 'pgp_helm_pwd')]) {

                    configFileProvider([configFile(fileId: 'pgp-helm', targetLocation: "secret.asc")

                    ]) {

                        sh "chmod u+x ./deploy.sh"

                        sh "./deploy.sh -e ${params.env} -c ${params.chart} -p ${pgp_helm_pwd}"
                    }
                }
            }
        }
    }
}
