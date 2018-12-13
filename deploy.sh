#!/bin/bash -x

env="default"

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

release="${chart}-${env}"

mkdir ~/.gnupg
chmod 700 ~/.gnupg

echo use-agent >> ~/.gnupg/gpg.conf
echo pinentry-mode loopback >> ~/.gnupg/gpg.conf
#echo no-tty >> ~/.gnupg/gpg.conf
echo allow-loopback-pinentry >> ~/.gnupg/gpg-agent.conf

gpgconf --reload gpg-agent

echo ${password} | gpg2 --batch --import secret.asc
echo ${password} > key.txt
touch dummy.txt
gpg --batch --yes --passphrase-file key.txt --pinentry-mode=loopback -s dummy.txt # sign dummy file to unlock agent

gpg --version
gpg --list-keys

helm init --client-only
helm plugin install https://github.com/futuresimple/helm-secrets
helm repo add softeamouest-opus-charts https://softeamouest-opus.github.io/charts

sops --version

options="--namespace ${env} "

[ -z "$image" ] && options="$options --set-string image.tag=${image} "

test -e ${chart}/${env}/secrets.yaml && options="$options --values ${chart}/${env}/secrets.yaml "

test -e ${chart}/${env}/secrets.yaml && options="$options --values ${chart}/${env}/values.yaml "

echo $options

nbRelease=`helm list --namespace ${env} | grep ^${release} | wc -l`

if [ $nbRelease=='0' ]; then
    helm secrets install --name ${release} ${options} softeamouest-opus-charts/${chart};
fi

if [ $nbRelease=='1' ]; then
    helm secrets upgrade ${release} softeamouest-opus-charts/${chart} ${options};
fi
