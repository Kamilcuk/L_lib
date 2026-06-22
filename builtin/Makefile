MAKEFLAGS = -rR
SHELL = bash

all:
	cmake -S . -B build -DL_DEV=1
	cmake --build build
	./test.sh

format:
	clang-format -i src/*.c src/*.h

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

sh: all
	bash --init-file <(echo 'enable -f ./build/L_builtin.so L_builtin')
