ARG VERSION=latest
FROM bash:${VERSION} AS l_lib
COPY bin/L_lib.sh /bin
RUN L_lib.sh

FROM l_lib AS test
RUN L_lib.sh test

FROM koalaman/shellcheck AS shellcheck
COPY bin/L_lib.sh .
RUN ["shellcheck", "L_lib.sh"]

FROM alpine AS md1
RUN apk add --no-cache pandoc gawk
COPY bin/L_lib.sh .
COPY shdoc/shdoc .
RUN set -x && mkdir -vp public && \
  ./shdoc \
    -vcfg_source_link='https://github.com/Kamilcuk/L_lib.sh/blob/main/bin/L_lib.sh' \
    -vcfg_variable_rgx='L_.*' \
    L_lib.sh >public/index.md
FROM scratch AS md
COPY --from=md1 public /

FROM md1 AS doc1
RUN pandoc -f markdown public/index.md >public/index.html
FROM scratch AS doc
COPY --from=doc1 public /
