PWD := $(shell pwd)
SPEC_INFO := $(shell uname -s)-$(shell uname -m)-$(shell python3 -c "from platform import python_version;print(python_version())")

build_cmake_make:
	@(mkdir -p build/${SPEC_INFO}; cd build/${SPEC_INFO}; cmake ../.. -DCMAKE_BUILD_TYPE=Release; make;)

build_cmake_ninja:
	@(mkdir -p build/${SPEC_INFO}; cd build/${SPEC_INFO}; cmake ../.. -DCMAKE_BUILD_TYPE=Release -G Ninja; ninja;)

build_zig:
	zig build -Drelease-fast=true

clean:
	-@rm -rf ${PWD}/build
	-@rm -rf ${PWD}/zig-out
	-@rm -rf ${PWD}/zig-cache
