MAKEFLAGS = -rR
SHELL = bash

B ?= build
BASH_INC ?= /usr/include/bash
BASH ?= bash

.PHONY: all build test bash3.2 bash4.0 format tidy cppcheck clean sh

all: build test

build:
	cmake -S . -B $(B) -DL_DEV=1 -DBASH_INC=$(BASH_INC)
	cmake --build $(B)

test:
	B=$(B) $(BASH) ./test.sh
	$(MAKE) check-format
	$(MAKE) tidy
	$(MAKE) cppcheck

format:
	clang-format -i src/*.c src/*.h

check-format:
	clang-format --dry-run --Werror src/*.c src/*.h

tidy:
	@if [ -f build/compile_commands.json ]; then \
		cp build/compile_commands.json build/compile_commands.bak && \
		sed -i 's/ -fanalyzer//g' build/compile_commands.json && \
		clang-tidy -p build src/*.c && \
		mv build/compile_commands.bak build/compile_commands.json; \
	else \
		echo "Error: build/compile_commands.json not found. Run make first."; \
		exit 1; \
	fi

cppcheck:
	@if [ -f build/compile_commands.json ]; then \
		cppcheck --project=build/compile_commands.json --suppress=missingIncludeSystem; \
	else \
		echo "Error: build/compile_commands.json not found. Run make first."; \
		exit 1; \
	fi

clean:
	rm -rf build compile_commands.json

sh: build
	bash --init-file <(echo 'enable -f ./build/L_builtin.so L_builtin')
