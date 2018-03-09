FROM centos:7.4.1708 as builder
MAINTAINER Craig Dodd
ARG BITCOIN_TAG=master

# Copy the gpg keys for repository verification
COPY assets/*.asc /root/rpm-gpg-keys/

# Install the gpg keys and the EPEL repo
RUN yum clean all && \
    rpm --import /root/rpm-gpg-keys/*.asc && \
    yum install -y https://archive.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm

# Install the build dependencies
RUN yum install -y \
    autoconf \
    automake \
    boost-devel \
    file \
    gcc-c++ \
    git \
    libdb4-cxx \
    libdb4-cxx-devel \
    libevent-devel \
    libtool \
    make \
    openssl-devel \
    which

# Create the bitcoin user and switch to it
RUN useradd builder
USER builder

# Clone the bitcoin repo, checkout the given tag, and run the build
RUN git clone https://github.com/bitcoin/bitcoin.git /tmp/bitcoin && \
    cd /tmp/bitcoin && \
    git checkout $BITCOIN_TAG && \
    ./autogen.sh && \
    ./configure --without-gui --prefix=/tmp/output && \
    make

# Switch back to root and run "make install"
USER root
RUN cd /tmp/bitcoin && make install

FROM centos:7.4.1708
MAINTAINER Craig Dodd

# Copy the gpg keys for repo verification
COPY assets/*.asc /root/rpm-gpg-keys/

# Install the EPEL repo
RUN yum clean all && \
    rpm --import /root/rpm-gpg-keys/*.asc && \
    yum install -y https://archive.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm && \
    rm -rf /root/rpm-gpg-keys

# Install the bitcoin runtime dependencies
RUN yum install -y \
    boost-devel \
    libdb4-cxx-devel \
    libevent-devel

# Copy the bitcoin binaries from the builder image
COPY --from=builder /tmp/output/ /opt/bitcoin

# Copy the bitcoind wrapper script
COPY assets/bitcoind-wrapper /bitcoind-wrapper

# Create the bitcoin user
RUN useradd bitcoin

# Define the docker volumes
# /etc/bitcoin = config, /var/bitcoin = bitcoin "datadir"
VOLUME ["/etc/bitcoin", "/var/bitcoin"]

# Expoose the bitcoin ports
# 8332 = Bitcoin API, 8333 = Bitcoin
EXPOSE 8332 8333

ENTRYPOINT ["/bitcoind-wrapper", "-conf=/etc/bitcoin/bitcoin.conf", "-printtoconsole"]
