MAKEFLAGS = -rR --warn-undefined-variables --no-print-directories
SHELL = bash
GNUMAKEFLAGS =
export PROGRESS_NO_TRUNC=1
export DOCKER_BUILDKIT=1
export DOCKER_PROGRESS=plain
ARGS ?=

all: test doc
	@echo SUCCESS all
test:
	./bin/L_lib.sh test $(ARGS)
	$(MAKE) test_bash5.2
	$(MAKE) test_bash4.4
	$(MAKE) shellcheck
	@echo SUCCESS test
test_bash%:
	docker build --build-arg VERSION=$* --target test .
shellcheck:
	docker build --target shellcheck .
shdoc:
	if [[ ! -e shdoc ]]; then git clone https://github.com/kamilcuk/shdoc.git; fi
doc: shdoc
	rm -vf public/index.md public/index.html
	docker buildx build --pull --target doc --output type=local,dest=public .
	$(MAKE) doc_test
	@echo SUCCESS doc
doc_test:
	grep -q L_LOGLEVEL_CRITICAL public/index.md
	grep -q L_dryrun public/index.md
	grep -q L_log_level public/index.md
	ls -la public
	test $$(find public -type f | wc -l) = 2
doc_open: doc
	xdg-open public/index.html
md: shdoc
	rm -f public/index.md
	docker build --target md --output public .
md_open:
	xdg-open public/index.md
.PHONY: test shellcheck shdoc doc doc_open md md_open
