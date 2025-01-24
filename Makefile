SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c

PART ?= xczu7ev-ffvc1156-2-e
OUTDIR ?= $(TOP)
SYNTH_ARGS ?= 

deps = $(shell cat build/$(OUTDIR)/synth.f)

src_dir = $(CURDIR)/examples
build_dir = $(CURDIR)/build

all: vivado
.PHONY: all clean vivado add_deps

build/$(OUTDIR)/done: vivado.tcl $(deps)	
	vivado -mode batch -source vivado.tcl -tclargs -part $(PART) -top $(TOP) -out ${OUTDIR} -synth "${SYNTH_ARGS}"> build/${OUTDIR}/run.log

vivado: build/$(OUTDIR)/done

clean:
	rm -f *.log
	rm -f *.jou

ultraclean: clean
	rm -rf build