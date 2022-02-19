# README #

This is Dode's Helm Chart for Keycloak

## Prerequisites ##

Build an optimized Keycloak Quarkus image:

    docker build . -t 192.168.3.3:5000/dode/keycloak

To allow access to local insecure registry, edit `/etc/rancher/rke2/registries.yaml`:  

    mirrors:
      "192.168.3.3:5000":
        endpoint:
          - "http://192.168.3.3:5000"

### Database ###

An external database, i.e. PostgreSQL

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

Create a secret for the cert + key:

    apiVersion: v1
    kind: Secret
    metadata:
      name: ca-key-pair
      namespace: dode
    data:
      tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUR5VENDQXJH...
      tls.key: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJ...

Create a CA issuer:

    apiVersion: cert-manager.io/v1
    kind: Issuer
    metadata:
      name: ca-issuer
      namespace: dode
    spec:
      ca:
        secretName: ca-key-pair

## Install Chart ##

* Set database coordinates in `values.yaml`
* Update `keycloak-db-secret.yaml` if necessary
* Set `keycloak.hostname` in `values.yaml`
* Install the chart!
