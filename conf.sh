#!/bin/sh -x

mkdir /home/jenkins/.gnupg
chmod 600 /home/jenkins/.gnupg

echo use-agent >> /home/jenkins/.gnupg/gpg.conf
echo pinentry-mode loopback >> /home/jenkins/.gnupg/gpg.conf
echo no-tty >> ~/.gnupg/gpg.conf
echo allow-loopback-pinentry >> /home/jenkins/.gnupg/gpg-agent.conf

gpgconf --reload gpg-agent

//sh 'echo export GPG_TTY=/dev/tty >> ~/.profile'

gpg --batch --import secret.asc
gpg --version
gpg --list-keys

helm init --client-only
helm plugin install https://github.com/futuresimple/helm-secrets
helm repo add softeamouest-opus-charts https://softeamouest-opus.github.io/charts

sops --version
