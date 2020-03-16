.DEFAULT_GOAL := all

.PHONY: build64 build32 all clean install

DESTDIR ?= /
PREFIX ?= $(HOME)/.local

MESON_FILES := meson.build src/meson.build shader/meson.build config/meson.build meson_options.txt
MESON_FLAGS += --buildtype release --prefix $(PREFIX)
DIST_ID ?= $(shell . /etc/os-release; echo $$ID)
MESON_CROSS_FILE_32 ?= meson-m32-$(DIST_ID).txt
MESON_FLAGS_32 += --cross-file $(MESON_CROSS_FILE_32)

INSTALL_BUILD_DIRS := build/Release32 build/Release64

build/Release64/build.ninja: $(MESON_FILES)
	meson $(MESON_FLAGS) $(@D)

build/Release32/build.ninja: $(MESON_FILES) $(MESON_CROSS_FILE_32)
	meson $(MESON_FLAGS) $(MESON_FLAGS_32) $(@D)

build64: build/Release64/build.ninja
	ninja -C $(<D)

build32: build/Release32/build.ninja
	ninja -C $(<D)

all: build64 build32

clean:
	[ ! -d build/Release32 ] || rm -rf build/Release32
	[ ! -d build/Release64 ] || rm -rf build/Release64

install: all
	$(foreach dir, $(INSTALL_BUILD_DIRS), DESTDIR=$(DESTDIR) ninja -C $(dir) install; )
