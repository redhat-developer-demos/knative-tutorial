FROM docker.io/antora/antora as builder

ADD . /antora/

RUN antora generate --stacktrace site.yml

FROM registry.access.redhat.com/rhscl/httpd-24-rhel7

COPY --from=builder /antora/gh-pages/ /var/www/html/
