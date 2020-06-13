FROM l.gcr.io/google/bazel:latest
WORKDIR /tmp

RUN wget wget https://ftp.cae.tntech.edu/ubuntu/pool/main/a/apt/apt-transport-https_1.2.32ubuntu0.1_amd64.deb && \
dpkg -i apt-transport-https_1.2.32ubuntu0.1_amd64.deb && \
rm apt-transport-https_1.2.32ubuntu0.1_amd64.deb && \
sed -i 's/http:/https:/g' /etc/apt/sources.list && \
sed -i 's/archive.ubuntu.com/mirror.us.leaseweb.net/g' /etc/apt/sources.list && \
sed -i 's/security.ubuntu.com/mirror.us.leaseweb.net/g' /etc/apt/sources.list && \
apt-get update

RUN apt-get install emacs
