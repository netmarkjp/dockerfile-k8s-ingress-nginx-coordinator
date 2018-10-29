# kubernetes-ingress-nginx-coordinator

# motivation

Enable multitenant HTTP/HTTPS web application platform
on small local on-premis Kubernetes cluster, without Loadbalancer, without VIP.

- multitenant with using ingress-nginx
- DNS `*.example.com` set to node's ip addresses
- `ingress-nginx` has wildcard SSL certification
- `ingress-nginx` expose port 80,443. Service with `NodePort`

## Overview

```
foo.example.com => (DNS RoundRobin) => [Node_IP:80/443] => (iptables) => [Service: ingress-nginx:80/443] => [Service: each webapp:80] => [each webapp's Pods]
```

After `[Service: ingress-nginx:80/443]` are the Kubernetes world.

## Usage

1. [setup Kubernetes cluster with kubeadm](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/)
1. setup [ingress-nginx](https://github.com/kubernetes/ingress-nginx)
1. create secret `kubeconfig`
    ```bash
    kubectl create secret generic kubeconfig -n kube-system --from-file=kubeconfig=/etc/kubernetes/admin.yml
    ```
1. create DaemonSet
    ```bash
    kubectl apply -f kubernetes-ingress-nginx-coordinator.yml
    ```
