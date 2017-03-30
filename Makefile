TOP=$(CURDIR)
include $(TOP)/paths.mk

all: buildeverything

CANARY_FOR_BAD_CLONING = external/mono/external/boringssl/LICENSE

$(CANARY_FOR_BAD_CLONING):
	git submodule update --init --recursive
	
buildeverything: $(CANARY_FOR_BAD_CLONING)
	make -C sdks all &&	\
	make -C android all

.PHONY: clean buildeverything
