#!/bin/bash -x

while getopts "e:c:i:p:" arg; do
  case $arg in
    e)
      env=$OPTARG
      ;;
    c)
      chart=$OPTARG
      ;;
    i)
      image=$OPTARG
      ;;
    p)
      password=$OPTARG
      ;;
  esac
done

mkdir ~/.gnupg
chmod 700 ~/.gnupg

#echo use-agent >> ~/.gnupg/gpg.conf
#echo pinentry-mode loopback >> ~/.gnupg/gpg.conf
#echo allow-loopback-pinentry >> ~/.gnupg/gpg-agent.conf

#gpgconf --reload gpg-agent

gpg --version
sops --version
helm version

echo ${password} | gpg2 --batch --import secret.asc
echo ${password} > key.txt
touch dummy.txt
gpg --batch --yes --passphrase-file key.txt --pinentry-mode=loopback -s dummy.txt # sign dummy file to unlock agent

helm init --client-only
helm plugin install https://github.com/futuresimple/helm-secrets
helm repo add softeamouest-opus-charts https://softeamouest-opus.github.io/charts

application="helm"

[ -z "$env" ] && release="${chart}" || release="${chart}-${env}"

[ -z "$env" ] && env="default"

options="--namespace ${env} "

[ -z "$image" ] || options="$options --set-string image.tag=${image} "

[ -e ${chart}/${env}/secrets.yaml ] && options="$options --values ${chart}/${env}/secrets.yaml "

[ -e ${chart}/${env}/secrets.yaml ] && application="$application secrets"

[ -e ${chart}/${env}/values.yaml ] && options="$options --values ${chart}/${env}/values.yaml "

nbRelease=`helm list --namespace ${env} | grep ^${release} | wc -l`

if [ "$nbRelease" = "0" ]; then
   ${application} install --name ${release} ${options} softeamouest-opus-charts/${chart};
fi

if [ "$nbRelease" = "1" ]; then
   ${application} upgrade ${release} softeamouest-opus-charts/${chart} ${options};
fi
