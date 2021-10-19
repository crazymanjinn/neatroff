AFMS := $(wildcard fonts/postscript/*.afm)
OTFS := $(wildcard fonts/truetype/*.otf)
TTFS := $(wildcard fonts/truetype/*.ttf)
OUT := $(notdir $(basename $(OTFS) $(TTFS)))

MKFN := mkfn

.PHONY: all
all: $(addprefix build/devutf/,$(OUT)) build/gen.sh.done

build/devutf/%: fonts/truetype/%.[ot]tf | build/devutf
	$(MKFN) -b -o < $< > $@

build/gen.sh.done: $(AFMS) | build
	$${GENSH:?} fonts/postscript build/devutf > /dev/null
	touch $@

build build/devutf:
	mkdir -p $@

datarootdir := /usr/local/share
INSTALLDIR := $(DESTDIR)$(datarootdir)/neatroff/font/devutf

.PHONY: install
install:
	mkdir -p $(INSTALLDIR)
	find build/devutf -maxdepth 1 -type f -print0 | \
		xargs -0 -tr cp --reflink=auto -t $(INSTALLDIR)
