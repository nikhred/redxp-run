SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c

PART ?= xczu7ev-ffvc1156-2-e

deps = $(shell cat build/$(TOP)/dependencies.f)

src_dir = $(CURDIR)/examples
build_dir = $(CURDIR)/build

all: vivado
.PHONY: all clean vivado add_deps
 
build/$(TOP)/done: vivado.tcl $(deps)
	vivado -mode batch -source vivado.tcl -tclargs -part $(PART) -top $(TOP)

# add_deps: build/$(TOP)/dependencies.f
# 	deps=$$(cat build/$(TOP)/dependencies.f); \
# 	echo "Dependencies: $$deps";

# @$(shell cat $(DEPENDENCIES_FILE)) > $@
# deps = $(shell cat build/$(TOP)/dependencies.f)

vivado: build/$(TOP)/done

clean:
	rm -f *.log
	rm -f *.jou

ultraclean:
	rm -rf build