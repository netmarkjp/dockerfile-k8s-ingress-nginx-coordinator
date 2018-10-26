FROM centos:7

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && install -m 755 kubectl /usr/local/bin/kubectl
RUN yum -y install iptables && yum clean all
ENV PATH $PATH:/usr/local/bin

COPY daemon.sh /opt/daemon.sh
COPY reconfigure.sh /opt/reconfigure.sh

ENTRYPOINT ["/opt/daemon.sh"]
