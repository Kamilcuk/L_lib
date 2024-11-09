ARG VERSION=latest
FROM bash:${VERSION} AS l_lib
COPY ./bin/L_lib.sh /bin

FROM l_lib AS test
RUN L_lib.sh --unittest
