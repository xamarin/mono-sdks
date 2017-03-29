TOP=$(CURDIR)
include $(TOP)/paths.mk

all:
	make -C sdks all &&	\
	make -C android all

.PHONY: clean
