#!/bin/sh -x

mkdir ~/.gnupg
chmod 700 ~/.gnupg

echo use-agent >> ~/.gnupg/gpg.conf
echo pinentry-mode loopback >> ~/.gnupg/gpg.conf
#echo no-tty >> ~/.gnupg/gpg.conf
echo allow-loopback-pinentry >> ~/.gnupg/gpg-agent.conf

gpgconf --reload gpg-agent

echo softeam44 | gpg2 --batch --import secret.asc
echo softeam44 > key.txt
touch dummy.txt
gpg --batch --yes --passphrase-file key.txt --pinentry-mode=loopback -s dummy.txt # sign dummy file to unlock agent

gpg --version
gpg --list-keys

helm init --client-only
helm plugin install https://github.com/futuresimple/helm-secrets
helm repo add softeamouest-opus-charts https://softeamouest-opus.github.io/charts

sops --version

helm secrets install --name books-api-dev --namespace dev --values books-api/dev/values.yaml --values books-api/dev/secrets.yaml softeamouest-opus-charts/books-api
