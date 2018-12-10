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
                        string(defaultValue: '', description: 'URL de l application', name: 'alias'),
                        string(defaultValue: 'dev', description: 'Environnement de déploiement', name: 'env')
                ])
        ])

        stage('CHECKOUT') {
            checkout scm;
        }

        container('helm') {

            stage('upgrade') {

                withCredentials([string(credentialsId: 'registry_url', variable: 'registry_url'),
                                 string(credentialsId: 'pgp_helm_pwd', variable: 'pgp_helm_pwd')]) {

                    configFileProvider([configFile(fileId: 'pgp-helm', targetLocation: "pgp-helm.asc")

                    ]) {

                        sh "gpg --import secret.asc"

                        sh "helm init --client-only"

                        sh "helm repo add softeamouest-opus-charts https://softeamouest-opus.github.io/charts"

                        def platform = params.env == 'prod' ? '' : '-' + params.env

                        def release = params.chart + "-" + params.env

                        def url = params.alias == '' ? "${params.chart}${platform}.k8.wildwidewest.xyz" : "${params.alias}${platform}.k8.wildwidewest.xyz"

                        def options = "--namespace ${params.env} --values secrets.yaml --set-string env=${platform},image.tag=${params.image} softeamouest-opus-charts/${params.chart} --set ingress.hosts[0]=${url},ingress.tls[0].hosts[0]=${url}"

                        sh "if [ `helm list --namespace ${params.env} | grep ^${release} | wc -l` == '0' ]; then helm secrets install --name ${release} ${options}; fi"

                        sh "if [ `helm list --namespace ${params.env} | grep ^${release} | wc -l` == '1' ]; then helm secrets upgrade ${release} ${options}; fi"
                    }

                }
            }
        }
    }
}
