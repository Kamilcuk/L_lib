ARG VERSION=latest
FROM bash:${VERSION} AS app
COPY bin/L_lib.sh /bin
RUN L_lib.sh --help

FROM app AS test
COPY tests/test.sh /bin
RUN test.sh

FROM koalaman/shellcheck AS shellcheck
COPY bin/L_lib.sh /
RUN ["shellcheck", "/L_lib.sh"]

FROM python:3.13-alpine AS doc1
COPY docs/requirements.txt docs/requirements.txt
RUN pip install -r docs/requirements.txt
WORKDIR /app
COPY docs docs
COPY bin bin
COPY README.md .
COPY LICENSE .
COPY mkdocs.yml .
RUN mkdocs build
FROM scratch AS doc
COPY --from=doc1 /app/site /
