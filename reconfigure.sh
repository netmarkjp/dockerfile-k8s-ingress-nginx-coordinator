#!/bin/bash

set -e

NODE_IPS=$(kubectl --kubeconfig=$PATH_TO_KUBE_CONFIG get nodes -l "node-role.kubernetes.io/master!=" -o jsonpath='{range .items[*]}{.status.addresses[].address},{end}' | sed 's/,$//')
if [[ "${NODE_IPS}" == "" ]]; then
    echo '<NODE_IPS> is required. ex: 192.168.0.11,192.168.0.12'
    exit 1
fi

DESTINATION_IP=$(kubectl --kubeconfig=$PATH_TO_KUBE_CONFIG get ep ingress-nginx -n ingress-nginx -o jsonpath="{ .subsets[].addresses[].ip }")
if [[ "${DESTINATION_IP}" == "" ]]; then
    echo '<DESTINATION_IP> is required. ex: 10.244.1.2'
    exit 1
fi

CHAIN_NAME="INGRESS-NGINX-COORDINATOR"
CHAIN_NAME_SWP="INGRESS-NGINX-COORDINATOR-SWP"

# initialise
iptables -t nat -L ${CHAIN_NAME_SWP:?} >/dev/null 2>&1 && iptables -t nat -F ${CHAIN_NAME_SWP:?} || (iptables -t nat -N ${CHAIN_NAME_SWP:?} && iptables -t nat -I PREROUTING 1 -j ${CHAIN_NAME_SWP:?})

iptables -t nat -A ${CHAIN_NAME_SWP:?} -p tcp --dport 80  -d ${NODE_IPS:?} -j DNAT --to-destination ${DESTINATION_IP:?}:80
iptables -t nat -A ${CHAIN_NAME_SWP:?} -p tcp --dport 443 -d ${NODE_IPS:?} -j DNAT --to-destination ${DESTINATION_IP:?}:443

iptables -t nat -L ${CHAIN_NAME:?} >/dev/null 2>&1 && iptables -t nat -F ${CHAIN_NAME:?} || (iptables -t nat -N ${CHAIN_NAME:?} && iptables -t nat -I PREROUTING 2 -j ${CHAIN_NAME:?})

iptables -t nat -A ${CHAIN_NAME:?} -p tcp --dport 80  -d ${NODE_IPS:?} -j DNAT --to-destination ${DESTINATION_IP:?}:80
iptables -t nat -A ${CHAIN_NAME:?} -p tcp --dport 443 -d ${NODE_IPS:?} -j DNAT --to-destination ${DESTINATION_IP:?}:443

iptables -t nat -F ${CHAIN_NAME_SWP:?}
