FROM centos:7

RUN USELESS="\
        git \
        less \
        openssh \
        openssh-clients \
        perl \
        perl-Carp \
        perl-Encode \
        perl-Error \
        perl-Exporter \
        perl-File-Path \
        perl-File-Temp \
        perl-Filter \
        perl-Getopt-Long \
        perl-Git \
        perl-HTTP-Tiny \
        perl-PathTools \
        perl-Pod-Escapes \
        perl-Pod-Perldoc \
        perl-Pod-Simple \
        perl-Pod-Usage \
        perl-Scalar-List-Utils \
        perl-Socket \
        perl-Storable \
        perl-TermReadKey \
        perl-Text-ParseWords \
        perl-Time-HiRes \
        perl-Time-Local \
        perl-constant \
        perl-libs \
        perl-macros \
        perl-parent \
        perl-podlators \
        perl-threads \
        perl-threads-shared \
        rsync \
        " \
    && rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 \
    && yum -y \
        --setopt=tsflags=nodocs \
        --setopt=override_install_langs=en_US.utf8 \
        install \
        centos-release-openstack-train \
    && rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud \
    && rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Storage \
    && yum -y update \
    && yum -y \
        --setopt=tsflags=nodocs \
        --setopt=override_install_langs=en_US.utf8 \
        install \
        bridge-utils \
        dpdk \
        driverctl \
        libibverbs \
        openvswitch \
        os-net-config \
    && rpm -e --nodeps $USELESS \
    && yum clean all \
    && rm -rf /var/log/{lastlog,faillog,yum.log}
