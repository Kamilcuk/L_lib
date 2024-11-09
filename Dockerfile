ARG VERSION=latest
FROM bash:${VERSION} AS L_lib
COPY ./bin/L_lib.sh /bin

FROM L_lib AS test
RUN L_lib.sh --unittest
