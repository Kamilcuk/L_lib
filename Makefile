MAKEFLAGS = -rR --warn-undefined-variables --no-print-directories
SHELL = bash
export PROGRESS_NO_TRUNC=1
export DOCKER_BUILDKIT=1
export DOCKER_PROGRESS=plain

test:
	docker build --build-arg VERSION=5.2 --target test .
	$(MAKE) shellcheck
shellcheck:
	docker build --target shellcheck .
shdoc:
	if [[ ! -e shdoc ]]; then git clone https://github.com/kamilcuk/shdoc.git; fi
doc: shdoc
	rm -f public/index.md public/index.html
	docker build --target doc --output public .
	grep -q L_LOGLEVEL_CRITICAL public/index.md
	grep -q L_DRYRUN public/index.md
doc_open: doc
	xdg-open public/index.html
md: shdoc
	rm -f public/index.md
	docker build --target md --output public .
md_open:
	xdg-open public/index.md

