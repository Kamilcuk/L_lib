MAKEFLAGS = -rR --warn-undefined-variables --no-print-directories
SHELL = bash
GNUMAKEFLAGS =
export PROGRESS_NO_TRUNC=1
export DOCKER_BUILDKIT=1
export DOCKER_PROGRESS=plain
ARGS ?=
DOCKERTERM = $(value MAKE_TERMOUT, -ti -eTERM)
DOCKERHISTORY = --mount type=bind,source=$(CURDIR)/.bash_history,target=/.bash_history \
	-eHISTCONTROL=ignoreboth:erasedups -eHISTFILE=/.bash_history
define NL


endef


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
		bash:$* ./bin/L_lib.sh test $(ARGS)
# docker build --build-arg VERSION=$* --target test .

shellcheck:
	docker build --target shellcheck .
shellcheckall:
	docker build --target shellcheckall .
shellchecklocal:
	# shellcheck $(ARGS) bin/L_lib.sh
	scripts/shellcheckparser_off.sh bin/L_lib.sh | shellcheck $(ARGS) -
shellcheckvim:
	scripts/shellcheckparser_off.sh bin/L_lib.sh | shellcheck -fgcc $(ARGS) - | sed 's@^-:@bin/L_lib.sh:@'
shellcheckvimstyle: ARGS = -Sstyle
shellcheckvimstyle: shellcheckvim
shellcheckvimall: ARGS = -oall -Sstyle
shellcheckvimall: shellcheckvim

term-%:
	@touch .bash_history
	docker run --rm -eTERM -ti -u $(shell id -u):$(shell id -g) \
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
		bash:$* -lc 'L_lib.sh $(ARGS)' bash

5.2test: test_bash5.2
4.4test: test_bash4.4
4.3test: test_bash4.3
4.2test: test_bash4.2
4.1test: test_bash4.1
4.0test: test_bash4.0
3.2test: test_bash3.2
5.2term: term-5.2
4.4term: term-4.4
4.3term: term-4.3
4.2term: term-4.2
4.1term: term-4.1
4.0term: term-4.0
3.2term: term-3.2
5.2termnoload: termnoload-5.2
4.4termnoload: termnoload-4.4
4.3termnoload: termnoload-4.3
4.2termnoload: termnoload-4.2
4.1termnoload: termnoload-4.1
4.0termnoload: termnoload-4.0
3.2termnoload: termnoload-3.2
5.2run: run-5.2
4.4run: run-4.4
4.3run: run-4.3
4.2run: run-4.2
4.1run: run-4.1
4.0run: run-4.0
3.2run: run-3.2

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
	grep -qw L_asa_set public/index.md
	grep -qw L_asa_dump public/index.md
	ls -la public
	test $$(find public -type f | wc -l) = 2
docopen: doc
	xdg-open "file://$$(readlink -f public/index.html)#l_asa_get"
md: shdoc
	rm -f public/index.md
	docker build --target md --output public .
md_open:
	xdg-open public/index.md
.PHONY: test shellcheck shdoc doc docopen md md_open
