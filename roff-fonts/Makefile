AFMS := $(wildcard fonts/afm/*.afm)
TTFS := $(wildcard fonts/ttf/*.ttf)
OTFS := $(wildcard fonts/otf/*.otf)

STDTROFFFONTS := R I B BI CR HR HI HB S1 S

OUT := $(notdir $(basename $(AFMS) $(OTFS) $(TTFS) $(STDTROFFFONTS)))

RES := 720
MKFN := mkfn
MKFNFLAGS := -r $(RES) -b -w

.PHONY: all
all: $(addprefix build/devutf/,$(OUT)) build/devutf/DESC build/Fontmap

build/devutf/%: fonts/ttf/%.ttf | build/devutf
	$(MKFN) $(MKFNFLAGS) -o -t $(notdir $(basename $<)) -f $(FONTDIR)/$(notdir $<) <$< >$@

build/devutf/%: fonts/otf/%.otf | build/devutf
	$(MKFN) $(MKFNFLAGS) -o -t $(notdir $(basename $<)) -f $(FONTDIR)/$(notdir $<) <$< >$@

build/devutf/%: fonts/afm/%.afm | build/devutf
	$(MKFN) $(MKFNFLAGS) -a -t $(notdir $(basename $<)) -f $(FONTDIR)/$(notdir $<) <$< >$@

build/devutf/R: fonts/afm/n021003l.afm | build/devutf
	$(MKFN) $(MKFNFLAGS) -a -t $(notdir $@) -pTimes-Roman <$< >$@
build/devutf/I: fonts/afm/n021023l.afm | build/devutf
	$(MKFN) $(MKFNFLAGS) -a -t $(notdir $@) -pTimes-Italic <$< >$@
build/devutf/B: fonts/afm/n021004l.afm | build/devutf
	$(MKFN) $(MKFNFLAGS) -a -t $(notdir $@) -pTimes-Bold <$< >$@
build/devutf/BI: fonts/afm/n021024l.afm | build/devutf
	$(MKFN) $(MKFNFLAGS) -a -t $(notdir $@) -pTimes-BoldItalic <$< >$@
build/devutf/CR: fonts/afm/n022003l.afm | build/devutf
	$(MKFN) $(MKFNFLAGS) -a -t $(notdir $@) -pCourier <$< >$@
build/devutf/HR: fonts/afm/n019003l.afm | build/devutf
	$(MKFN) $(MKFNFLAGS) -a -t $(notdir $@) -pHelvetica <$< >$@
build/devutf/HI: fonts/afm/n019023l.afm | build/devutf
	$(MKFN) $(MKFNFLAGS) -a -t $(notdir $@) -pHelvetica-Oblique <$< >$@
build/devutf/HB: fonts/afm/n019004l.afm | build/devutf
	$(MKFN) $(MKFNFLAGS) -a -t $(notdir $@) -pHelvetica-Bold <$< >$@
build/devutf/S: fonts/afm/s050000l.afm | build/devutf
	$(MKFN) $(MKFNFLAGS) -a -t $(notdir $@) -pSymbol -s <$< >$@
build/devutf/S1: fonts/afm/n021003l.afm | build/devutf
	$(MKFN) $(MKFNFLAGS) -a -t $(notdir $@) -pTimes-Roman -s <$< >$@

define DESC =
fonts 10 $(STDTROFFFONTS)
res $(RES)
hor 1
ver 1
unitwidth 10
endef
export DESC := $(DESC)

build/devutf/DESC: | build/devutf
	$(file >$@,$(DESC))

build/Fontmap: ./extract_font_names $(OTFS) $(TTFS) | build
	$(file >build/fonts.txt,$(wordlist 2,$(words $^),$^))
	./$< < build/fonts.txt 2>/dev/null > $@

build build/devutf:
	mkdir -p $@

datarootdir := /usr/local/share
INSTALLDIR := $(DESTDIR)$(datarootdir)

.PHONY: install
install:
	mkdir -p $(INSTALLDIR)/neatroff/font
	cp -r --reflink=auto build/devutf  $(INSTALLDIR)/neatroff/font
	cp -r --reflink=auto fonts $(INSTALLDIR)
	cp --reflink=auto build/Fontmap $(INSTALLDIR)/neatroff
