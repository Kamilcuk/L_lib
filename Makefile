MAKEFLAGS = -rR --warn-undefined-variables --no-print-directories
SHELL = bash
GNUMAKEFLAGS =
export PROGRESS_NO_TRUNC=1
export DOCKER_BUILDKIT=1
export DOCKER_PROGRESS=plain
ARGS ?=
DOCKERTERM = $(shell test -t 0 && printf -- -ti) -eTERM
DOCKERHISTORY = --mount type=bind,source=$(CURDIR)/.bash_history,target=/.bash_history \
	-eHISTCONTROL=ignoreboth:erasedups -eHISTFILE=/.bash_history

all: test doc
	@echo SUCCESS all

test: \
		test_local \
		shellcheck \
		test_bash5.2 \
		test_bash3.2 \
		test_bash4.4 \
		test_bash4.0 \
		test_bash4.3 \
		test_bash4.2 \
		test_bash4.1 \
		#
	@echo SUCCESS test
test_local:
	./bin/L_lib.sh test $(ARGS)
test_bash%:
	docker run --rm $(DOCKERTERM) \
		--mount type=bind,source=$(CURDIR),target=$(CURDIR),readonly -w $(CURDIR) \
		bash:$* ./bin/L_lib.sh test
# docker build --build-arg VERSION=$* --target test .
shellcheck:
	docker build --target shellcheck .

term-%:
	@touch .bash_history
	docker run --rm $(DOCKERTERM) -u $(shell id -u):$(shell id -g) \
		$(DOCKERHISTORY) \
		--mount type=bind,source=$(CURDIR)/bin/L_lib.sh,target=/etc/profile.d/L_lib.sh,readonly \
		--mount type=bind,source=$(CURDIR)/bin/L_lib.sh,target=/bin/L_lib.sh,readonly \
		--mount type=bind,source=$(CURDIR),target=$(CURDIR),readonly -w $(CURDIR) \
		bash:$* -l $(ARGS)
termnoload-%:
	@touch .bash_history
	docker run --rm $(DOCKERTERM) -u $(shell id -u):$(shell id -g) \
		$(DOCKERHISTORY) \
		--mount type=bind,source=$(CURDIR),target=$(CURDIR),readonly -w $(CURDIR) \
		bash:$* -l $(ARGS)
run-%:
	docker run --rm $(DOCKERTERM) -u $(shell id -u):$(shell id -g) \
		--mount type=bind,source=$(CURDIR)/bin/L_lib.sh,target=/bin/L_lib.sh,readonly \
		bash:$* -lc 'L_lib.sh "$$@"' bash $(ARGS)


shdoc:
	if [[ ! -e shdoc ]]; then git clone https://github.com/kamilcuk/shdoc.git; fi
doc: shdoc
	rm -vf public/index.md public/index.html
	docker buildx build --pull --target doc --output type=local,dest=public .
	$(MAKE) doctest
	@echo SUCCESS doc
doctest:
	grep -qw L_LOGLEVEL_CRITICAL public/index.md
	grep -qw L_dryrun public/index.md
	grep -qw _L_logconf_level public/index.md
	grep -qw L_sort public/index.md
	grep -qw L_log_level_to_int public/index.md
	ls -la public
	test $$(find public -type f | wc -l) = 2
docopen: doc
	xdg-open public/index.html
md: shdoc
	rm -f public/index.md
	docker build --target md --output public .
md_open:
	xdg-open public/index.md
.PHONY: test shellcheck shdoc doc docopen md md_open
