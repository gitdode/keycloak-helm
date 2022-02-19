FROM quay.io/keycloak/keycloak:latest as builder

ENV KC_METRICS_ENABLED=true
ENV KC_FEATURES=token-exchange,admin-fine-grained-authz
ENV KC_DB=postgres
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/lib/quarkus/ /opt/keycloak/lib/quarkus/
WORKDIR /opt/keycloak
ENV KEYCLOAK_ADMIN=keycloak
ENV KEYCLOAK_ADMIN_PASSWORD=keycloak
ENV KC_DB_URL=jdbc:postgresql://192.168.3.3:5432/keycloak
ENV KC_DB_USERNAME=keycloak
ENV KC_DB_PASSWORD=keycloak
# ENV KC_HOSTNAME=localhost:8443
ENV KC_HOSTNAME_STRICT=false
ENV KC_HTTP_ENABLED=true
ENV KC_PROXY=edge
ENV LANG=C.UTF-8
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start"] 
