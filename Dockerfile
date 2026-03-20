ARG VERSION=latest

FROM docker.io/library/bash:${VERSION} AS app
USER nobody:nogroup
COPY bin/L_lib.sh /bin/L_lib.sh
RUN /bin/L_lib.sh --help

FROM docker.io/library/bash:${VERSION} AS tester
RUN apk add --no-cache jq

FROM tester AS test
USER nobody:nogroup
COPY bin/L_lib.sh /bin/L_lib.sh
RUN /bin/L_lib.sh --help
COPY tests/ /tests/
COPY docs/ /docs/
COPY mkdocs.yml mkdocs.yml
ARG ARGS=""
RUN /tests/citest.sh ${ARGS}

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

FROM alpine:3.20 AS basher
RUN apk add --no-cache bash curl git coreutils
RUN touch /root/.profile
RUN curl -sSL https://raw.githubusercontent.com/basherpm/basher/master/install.sh | bash
ENV PATH=/root/.basher/bin:/root/.basher/cellar/bin:$PATH
COPY ./bash.yml /app/
COPY ./bin/ /app/bin/
RUN basher link /app kamilcuk/L_lib
RUN basher list -v
RUN L_lib.sh --help

FROM docker.io/library/bash:${VERSION} AS perfbash
RUN apk add --no-cache perf bubblewrap bc coreutils util-linux
COPY . /app/
WORKDIR /app
CMD ["./scripts/perfbash"]
