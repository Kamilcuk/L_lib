MAKEFLAGS = -rR --warn-undefined-variables --no-print-directories
SHELL = bash
GNUMAKEFLAGS =
export PROGRESS_NO_TRUNC=1
export DOCKER_BUILDKIT=1
export DOCKER_PROGRESS=plain
ARGS ?=
DOCKERTERM = -eTERM $(shell [ -t 0 ] && printf -- -t)
DOCKERHISTORY = --mount type=bind,source=$(CURDIR)/.bash_history,target=/.bash_history \
	-eHISTCONTROL=ignoreboth:erasedups -eHISTFILE=/.bash_history
define NL


endef


all: test doc
	@echo SUCCESS all

test_parallel:
	$(MAKE) -O -j$(shell nproc) test
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
		test_bash5.1 \
		test_bash5.0 \
		#
	@echo 'make test finished with SUCCESS'
test_local:
	./tests/test.sh $(ARGS)
test_bash%:
	docker run --rm $(DOCKERTERM) \
		--mount type=bind,source=$(CURDIR),target=$(CURDIR),readonly -w $(CURDIR) \
		bash:$* ./tests/test.sh $(ARGS)
test_docker%:
	docker build --build-arg VERSION=$* --target test .

shellcheck:
	docker build --target shellcheck .
shellcheckall:
	docker build --target shellcheckall .
shellchecklocal:
	shellcheck $(ARGS) bin/L_lib.sh
shellcheckvim:
	shellcheck -fgcc $(ARGS) bin/L_lib.sh | sed 's@^-:@bin/L_lib.sh:@'
shellcheckvimstyle: ARGS = -Sstyle
shellcheckvimstyle: shellcheckvim
shellcheckvimall: ARGS = -oall -Sstyle
shellcheckvimall: shellcheckvim

term-%:
	@touch .bash_history
	docker run --rm $(DOCKERTERM) -i -u $(shell id -u):$(shell id -g) \
		$(DOCKERHISTORY) \
		--mount type=bind,source=$(CURDIR)/bin/L_lib.sh,target=/etc/profile.d/L_lib.sh,readonly \
		--mount type=bind,source=$(CURDIR)/bin/L_lib.sh,target=/bin/L_lib.sh,readonly \
		--mount type=bind,source=$(CURDIR),target=$(CURDIR) -w $(CURDIR) \
		bash:$* -l $(ARGS)
termnoload-%:
	@touch .bash_history
	docker run --rm $(DOCKERTERM) -i -u $(shell id -u):$(shell id -g) \
		$(DOCKERHISTORY) \
		--mount type=bind,source=$(CURDIR),target=$(CURDIR),readonly -w $(CURDIR) \
		bash:$* -l $(ARGS)
run-%:
	docker run --rm $(DOCKERTERM) -u $(shell id -u):$(shell id -g) \
		--mount type=bind,source=$(CURDIR)/bin/L_lib.sh,target=/bin/L_lib.sh,readonly \
		bash:$* -lc 'L_lib.sh $(ARGS)' bash

5.3test: test_bash5.3-alpha
5.2test: test_bash5.2
5.1test: test_bash5.1
5.0test: test_bash5.0
4.4test: test_bash4.4
4.3test: test_bash4.3
4.2test: test_bash4.2
4.1test: test_bash4.1
4.0test: test_bash4.0
3.2test: test_bash3.2
3.1test: test_bash3.1
5.2term: term-5.2
4.4term: term-4.4
4.3term: term-4.3
4.2term: term-4.2
4.1term: term-4.1
4.0term: term-4.0
3.2term: term-3.2
3.1term: term-3.1
5.2termnoload: termnoload-5.2
4.4termnoload: termnoload-4.4
4.3termnoload: termnoload-4.3
4.2termnoload: termnoload-4.2
4.1termnoload: termnoload-4.1
4.0termnoload: termnoload-4.0
3.2termnoload: termnoload-3.2
5.2run: run-5.2
5.1run: run-5.1
5.0run: run-5.0
4.4run: run-4.4
4.3run: run-4.3
4.2run: run-4.2
4.1run: run-4.1
4.0run: run-4.0
3.2run: run-3.2

.PHONY: docs_build docs_serve
_docs:
	uvx --with-requirements=./docs/requirements.txt mkdocs $(WHAT)
docs_build: WHAT = build
docs_build: _docs
docs_serve: WHAT = serve
docs_serve: _docs
docs_serve2:
	uvx --with-requirements=./docs/requirements.txt --with-editable=../mkdocstrings-sh/ mkdocs serve
docs_docker:
	docker build --target doc --output type=local,dest=./public .

