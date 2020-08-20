#!/bin/bash

set -e

ME=$0

CUR=$(realpath $(dirname $0))

DATA_PATH=/data

REPO_FILE=$CUR/repo.tar.gz
ICT_ANSIBLE_FILE=$CUR/ict-ansible.tar.gz
OFFLINE_MODE=true

UNDERCLOUD_IP=
ENVIRONMENT_FILE=/etc/ict/globals.yml

yum_install(){

    yum_opts=""
    if [[ $OFFLINE_MODE == "true" ]]; then
        yum_opts="--disablerepo=* --enablerepo=_local"
    fi

    yum -y $yum_opts install $@
}

setup_offline_repo(){
    if [[ ! -f $REPO_FILE ]]; then
        echo "$REPO_FILE is not found"
        exit 1
    fi

    if [[ ! -d $DATA_PATH ]]; then
        mkdir -p $DATA_PATH
    fi

    tar xvf $REPO_FILE -C $DATA_PATH/

    # install createrepo
    if [[ ! -f /usr/bin/createrepo ]] && [[ ! -e $DATA_PATH/repo/repodata ]]; then
        yum -y localinstall \
            $(find $DATA_PATH/repo -type f \
                -name 'createrepo*' \
                -o -name 'deltarpm*' \
                -o -name 'python-deltarpm*' \
                -o -name 'libxml2-python*')
        createrepo $DATA_PATH/repo
    fi


    cat <<EOF > /etc/yum.repos.d/_local.repo
[_local]
name=local repo from filesystem
baseurl=file://$DATA_PATH/repo
enabled=0
gpgcheck=0
EOF
}

setup_ansible(){
    echo "installing ansible"
    # NOTE(Jeffrey4l): use python2-jinja2 which has a higher version
    yum_install ansible python2-jinja2 python2-netaddr
    echo "ansible is installed successfully"
}

setup_ict_ansible(){
    if [[ ! -d /root/ict-ansible ]]; then
        tar xvf $ICT_ANSIBLE_FILE -C /root
    fi
}

run_playbook(){
    echo Initializing undercloud environment
    mkdir -p /var/log/ict
    export ANSIBLE_LOG_PATH=/var/log/ict/undercloud.log
    ansible-playbook -i localhost, -c local \
        /root/ict-ansible/undercloud_config.yml \
        -e @$ENVIRONMENT_FILE
}

usage(){
    cat<<EOF
Usage:

    $ME [options]

Options:

    -h, --help           Show this usage information.
    -p, --print-example  Print an environment example file.
EOF
}

print_example(){

    cat <<EOF
---
######################
# required variables #
######################

# the deployment node ip
undercloud_ip: 192.168.2.100

control_interface: eth1
ip_version: "4"

# bios, uefi
default_deploy_boot_mode: bios

# vip
internal_vip: 192.168.3.2
public_vip: 192.168.1.2

# control & provision
control_subnet: 192.168.2.0/24
control_vlanid: 137

# public endpoint
public_subnet: 192.168.1.0/24
public_vlanid: 139
public_gateway: 192.168.139.1

# admin/internal endpoint
internal_subnet: 192.168.3.0/24
internal_vlanid: 136

# ceph public network
storage_subnet: 192.168.4.0/24
storage_vlanid: 134

# ceph cluster network
storagemgmt_subnet: 192.168.5.0/24
storagemgmt_vlanid: 135

domain_suffix: vim1.local

############
# services #
############
enable_horizon: true
horizon_port: 80
enable_portal: true
portal_port: 81

###############
# kernel type #
###############
kernel_type: keep

###############
# DPDK Option
###############
hugepages: 0
hugepagesz: 1G
dpdk_init: false
dpdk_socket_mem: "1024,0"
dpdk_lcore_list: "0,4"
pmd_cpu_list: "1,5"

###################################################
# normally, following variable no need be changed #
###################################################
package_path: $CUR
offline_mode: true
docker_registry: "{{ undercloud_ip }}:4000"
data_path: /data
EOF
}

SHORT_OPTS="pe:h"
LONG_OPTS="print-example,environment:help"

ARGS=$(getopt -o "${SHORT_OPTS}" -l "${LONG_OPTS}" --name "$ME" -- "$@") || { usage >&2; exit 2; }
eval set -- "$ARGS"


while [ "$#" -gt 0 ]; do
    case "$1" in

    --print-example|-p)
        print_example
        exit 0
        ;;
    --help|-h)
        usage
        exit 0
        ;;
    --)
        shift
        break
        ;;

    *)
        echo "error"
        exit 3
        ;;

    esac
done

if [[ ! -f $ENVIRONMENT_FILE ]]; then

    cat <<EOF
ERROR: Can not found environment file at $ENVIRONMENT_FILE, you can generate through

    $ME -p
EOF
    exit 4
fi

setup_offline_repo
setup_ansible

setup_ict_ansible

run_playbook
