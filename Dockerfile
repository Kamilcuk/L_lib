ARG VERSION=latest
FROM bash:${VERSION} AS app
COPY bin/L_lib.sh /bin
RUN L_lib.sh --help

FROM app AS test
RUN L_lib.sh test

FROM busybox AS shellcheck_prepare
COPY bin/L_lib.sh scripts/shellcheckparser_off.sh .
# This function is unparsable by shellcheck.
RUN set -x && \
  ./shellcheckparser_off.sh L_lib.sh >L_lib.sh.tmp && \
  mv -v L_lib.sh.tmp L_lib.sh
FROM koalaman/shellcheck AS shellcheck
COPY --from=shellcheck_prepare L_lib.sh .
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
RUN pandoc --number-sections -f markdown public/index.md >public/index.html
FROM scratch AS doc
COPY --from=doc1 public /
