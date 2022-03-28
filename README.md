# README #

This is Dode's Helm Chart for Keycloak

## Prerequisites ##

Tested with a "bare metal" RKE2.

### Image ###

#### Auto Build ####

This chart uses the "auto-build" profile to configure Keycloak at startup via
environment variables, using the official image.  
That way, startup takes longer and the image is mutable, but it is more flexible.

#### Alternative: Optimized Image ####

Set values in `Dockerfile`, then build and push the image:

      docker build . -t 192.168.3.3:5000/dode/keycloak
      docker push 192.168.3.3:5000/dode/keycloak

To allow access to local insecure registry, edit `/etc/rancher/rke2/registries.yaml`:

    mirrors:
      "192.168.3.3:5000":
        endpoint:
          - "http://192.168.3.3:5000"

Then set the optimized image as `keycloak.image` in `values.yaml` and replace 
`templates/keycloak-deployment.yaml` with `optimized/keycloak-deployment.yaml`.

### Storage ###

Storage for the database's data files can either be a local directory or an NFS share, 
see `storage` in `values.yaml`

### Hostname ###

The hostname for Keycloak is set as `keycloak.hostname` in `values.yaml`.

### Create Namespace ###

    kubectl create namespace dode

### TLS ###

For TLS, install cert-manager: https://cert-manager.io/docs/installation/  
To use your own CA: https://cert-manager.io/docs/configuration/ca/  
To secure ingresses: https://cert-manager.io/docs/usage/ingress/  

Create your own CA cert + key:  

    openssl genrsa -out rootCAKey.pem 2048
    openssl req -x509 -sha256 -new -nodes -key rootCAKey.pem -days 3650 -out rootCACert.pem

Encode the cert + key with Base64:  

    cat rootCAKey.pem | base64 -w0
    cat rootCACert.pem | base64 -w0

Create a secret for the cert + key as `ca-key-pair.yaml`:

    apiVersion: v1
    kind: Secret
    metadata:
      name: ca-key-pair
      namespace: dode
    data:
      tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUR5VENDQXJH...
      tls.key: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJ...

Apply it: `kubectl -n dode apply -f ca-key-pair.yaml`

Create a CA issuer as `ca-issuer.yaml`:

    apiVersion: cert-manager.io/v1
    kind: Issuer
    metadata:
      name: ca-issuer
      namespace: dode
    spec:
      ca:
        secretName: ca-key-pair

Apply it: `kubectl -n dode apply -f ca-issuer.yaml`

## Installation ##

### Create Secrets ###

For the database password:

    kubectl -n dode create secret generic keycloak-db-secret --from-literal=password=keycloak

For the Keycloak admin user ("keycloak"):

    kubectl -n dode create secret generic keycloak-user-secret --from-literal=password=keycloak

### Install the chart! ###

    helm -n dode upgrade --install keycloak .
