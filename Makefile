override TOPDIR := $(shell pwd)
override DEBUG := 0
override STATIC := 0
override SVB_FLAGS := -Wall -Wextra -DUSE_MMAP -DHOST -DSVB_WIN32 -DANDROID

$(error MINGW builds not yet supported)

ifeq ($(STATIC),1)
override SVB_FLAGS := -static $(SVB_FLAGS)
else
$(warning WARNING: Host libraries are statically linked)
$(warning WARNING: Using large mcmodel)
override SVB_FLAGS := -mcmodel=large $(SVB_FLAGS)
endif

ifeq ($(DEBUG),1)
override SVB_FLAGS := -g $(SVB_FLAGS) -DSVB_DEBUG
else
override SVB_FLAGS := $(SVB_FLAGS) -DNDEBUG -Oz
endif

override CC := clang
override CFLAGS := $(CFLAGS) $(SVB_FLAGS)
#override DCC := $(CC)
override CXX := clang++
override CXXSTD := c++2a
override CXXLIB := libc++
override CXXFLAGS := $(CXXFLAGS) -std=$(CXXSTD) -stdlib=$(CXXLIB) $(SVB_FLAGS)
#override GPP := g++
#ld is set for shared libs
override LD := clang
override LDXX := clang++ -std=$(CXXSTD) -stdlib=$(CXXLIB)
override LDFLAGS := -flto -lpthread
override STRIP := strip
override STRIPFLAGS := $(STRIPFLAGS) --strip-all
ifeq ($(DEBUG),1)
override STRIPFLAGS := --strip-dwo
endif
override AR := ar
override ARFLAGS := rcs
override LIBS :=

override OUT := $(TOPDIR)/out
override OBJ := $(OUT)/obj
override LIB := $(OBJ)/lib
override SLIB := $(LIB)/shared

override BIN_RES := $(OBJ)/bin.res
override DLL_RES := $(OBJ)/dll.res

# run make TARGET=windows for a mingw32 build
override E := .exe

ifeq ($(SVB_MINGW), 1)
INCLUDES := -I$(TOPDIR)/libnt/include
endif

override INCLUDES := $(INCLUDES) -Iinclude \
    -I$(TOPDIR)/external/libfdt \
    -I$(TOPDIR)/external/mincrypt/include \
    -Imagiskbase/include \
    -I$(TOPDIR)/external/zopfli/src \
    -I$(TOPDIR)/external/bzip2 \
    -I$(TOPDIR)/external/xz/src/liblzma/api \
    -I$(TOPDIR)/external/zlib \
    -I$(TOPDIR)/external/lz4/lib

.PHONY: all

MAGISKBOOT_SRC = \
    bootimg.cpp \
    hexpatch.cpp \
    compress.cpp \
    format.cpp \
    dtb.cpp \
    ramdisk.cpp \
    pattern.cpp \
    cpio.cpp \
    main.cpp
MAGISKBOOT_OBJ := $(patsubst %.cpp,$(OBJ)/magiskboot/%.o,$(MAGISKBOOT_SRC))

LIBBASE_SRC = \
    magiskbase/files.cpp \
    magiskbase/misc.cpp \
    magiskbase/xwrap.cpp \
    magiskbase/stream.cpp
LIBBASE_OBJ := $(patsubst %.cpp,$(OBJ)/%.o,$(LIBBASE_SRC))

LIBMINCRYPT_SRC = \
    external/mincrypt/dsa_sig.c \
    external/mincrypt/p256.c \
    external/mincrypt/p256_ec.c \
    external/mincrypt/p256_ecdsa.c \
    external/mincrypt/rsa.c \
    external/mincrypt/sha.c \
    external/mincrypt/sha256.c
LIBMINCRYPT_OBJ = $(patsubst %.c,$(OBJ)/%.o,$(LIBMINCRYPT_SRC))

LIBLZMA_SRC = \
    external/lzma/src/common/tuklib_cpucores.c \
    external/lzma/src/common/tuklib_exit.c \
    external/lzma/src/common/tuklib_mbstr_fw.c \
    external/lzma/src/common/tuklib_mbstr_width.c \
    external/lzma/src/common/tuklib_open_stdxxx.c \
    external/lzma/src/common/tuklib_physmem.c \
    external/lzma/src/common/tuklib_progname.c \
    external/lzma/src/liblzma/check/check.c \
    external/lzma/src/liblzma/check/crc32_fast.c \
    external/lzma/src/liblzma/check/crc32_table.c \
    external/lzma/src/liblzma/check/crc64_fast.c \
    external/lzma/src/liblzma/check/crc64_table.c \
    external/lzma/src/liblzma/check/sha256.c \
    external/lzma/src/liblzma/common/alone_decoder.c \
    external/lzma/src/liblzma/common/alone_encoder.c \
    external/lzma/src/liblzma/common/auto_decoder.c \
    external/lzma/src/liblzma/common/block_buffer_decoder.c \
    external/lzma/src/liblzma/common/block_buffer_encoder.c \
    external/lzma/src/liblzma/common/block_decoder.c \
    external/lzma/src/liblzma/common/block_encoder.c \
    external/lzma/src/liblzma/common/block_header_decoder.c \
    external/lzma/src/liblzma/common/block_header_encoder.c \
    external/lzma/src/liblzma/common/block_util.c \
    external/lzma/src/liblzma/common/common.c \
    external/lzma/src/liblzma/common/easy_buffer_encoder.c \
    external/lzma/src/liblzma/common/easy_decoder_memusage.c \
    external/lzma/src/liblzma/common/easy_encoder.c \
    external/lzma/src/liblzma/common/easy_encoder_memusage.c \
    external/lzma/src/liblzma/common/easy_preset.c \
    external/lzma/src/liblzma/common/filter_buffer_decoder.c \
    external/lzma/src/liblzma/common/filter_buffer_encoder.c \
    external/lzma/src/liblzma/common/filter_common.c \
    external/lzma/src/liblzma/common/filter_decoder.c \
    external/lzma/src/liblzma/common/filter_encoder.c \
    external/lzma/src/liblzma/common/filter_flags_decoder.c \
    external/lzma/src/liblzma/common/filter_flags_encoder.c \
    external/lzma/src/liblzma/common/hardware_cputhreads.c \
    external/lzma/src/liblzma/common/hardware_physmem.c \
    external/lzma/src/liblzma/common/index.c \
    external/lzma/src/liblzma/common/index_decoder.c \
    external/lzma/src/liblzma/common/index_encoder.c \
    external/lzma/src/liblzma/common/index_hash.c \
    external/lzma/src/liblzma/common/outqueue.c \
    external/lzma/src/liblzma/common/stream_buffer_decoder.c \
    external/lzma/src/liblzma/common/stream_buffer_encoder.c \
    external/lzma/src/liblzma/common/stream_decoder.c \
    external/lzma/src/liblzma/common/stream_encoder.c \
    external/lzma/src/liblzma/common/stream_encoder_mt.c \
    external/lzma/src/liblzma/common/stream_flags_common.c \
    external/lzma/src/liblzma/common/stream_flags_decoder.c \
    external/lzma/src/liblzma/common/stream_flags_encoder.c \
    external/lzma/src/liblzma/common/vli_decoder.c \
    external/lzma/src/liblzma/common/vli_encoder.c \
    external/lzma/src/liblzma/common/vli_size.c \
    external/lzma/src/liblzma/delta/delta_common.c \
    external/lzma/src/liblzma/delta/delta_decoder.c \
    external/lzma/src/liblzma/delta/delta_encoder.c \
    external/lzma/src/liblzma/lz/lz_decoder.c \
    external/lzma/src/liblzma/lz/lz_encoder.c \
    external/lzma/src/liblzma/lz/lz_encoder_mf.c \
    external/lzma/src/liblzma/lzma/fastpos_table.c \
    external/lzma/src/liblzma/lzma/lzma2_decoder.c \
    external/lzma/src/liblzma/lzma/lzma2_encoder.c \
    external/lzma/src/liblzma/lzma/lzma_decoder.c \
    external/lzma/src/liblzma/lzma/lzma_encoder.c \
    external/lzma/src/liblzma/lzma/lzma_encoder_optimum_fast.c \
    external/lzma/src/liblzma/lzma/lzma_encoder_optimum_normal.c \
    external/lzma/src/liblzma/lzma/lzma_encoder_presets.c \
    external/lzma/src/liblzma/rangecoder/price_table.c \
    external/lzma/src/liblzma/simple/arm.c \
    external/lzma/src/liblzma/simple/armthumb.c \
    external/lzma/src/liblzma/simple/ia64.c \
    external/lzma/src/liblzma/simple/powerpc.c \
    external/lzma/src/liblzma/simple/simple_coder.c \
    external/lzma/src/liblzma/simple/simple_decoder.c \
    external/lzma/src/liblzma/simple/simple_encoder.c \
    external/lzma/src/liblzma/simple/sparc.c \
    external/lzma/src/liblzma/simple/x86.c
LIBLZMA_INCLUDES = \
    -I$(TOPDIR)/external/xz_config \
    -I$(TOPDIR)/external/xz/src/common \
    -I$(TOPDIR)/external/xz/src/liblzma/api \
    -I$(TOPDIR)/external/xz/src/liblzma/check \
    -I$(TOPDIR)/external/xz/src/liblzma/common \
    -I$(TOPDIR)/external/xz/src/liblzma/delta \
    -I$(TOPDIR)/external/xz/src/liblzma/lz \
    -I$(TOPDIR)/external/xz/src/liblzma/lzma \
    -I$(TOPDIR)/external/xz/src/liblzma/rangecoder \
    -I$(TOPDIR)/external/xz/src/liblzma/simple \
    -I$(TOPDIR)/external/xz/src/liblzma
LIBLZMA_OBJ = $(patsubst %.c,$(OBJ)/%.o,$(LIBLZMA_SRC))

LIBBZ2_SRC = \
    external/bzip2/blocksort.c  \
    external/bzip2/huffman.c    \
    external/bzip2/crctable.c   \
    external/bzip2/randtable.c  \
    external/bzip2/compress.c   \
    external/bzip2/decompress.c \
    external/bzip2/bzlib.c
LIBBZ2_OBJ = $(patsubst %.c,$(OBJ)/%.o,$(LIBBZ2_SRC))

LIBLZ4_SRC = \
    external/lz4/lib/lz4.c \
    external/lz4/lib/lz4frame.c \
    external/lz4/lib/lz4hc.c \
    external/lz4/lib/xxhash.c
LIBLZ4_OBJ = $(patsubst %.c,$(OBJ)/%.o,$(LIBLZ4_SRC))

LIBZOPFLI_SRC = \
    external/zopfli/src/zopfli/blocksplitter.c \
    external/zopfli/src/zopfli/cache.c \
    external/zopfli/src/zopfli/deflate.c \
    external/zopfli/src/zopfli/gzip_container.c \
    external/zopfli/src/zopfli/hash.c \
    external/zopfli/src/zopfli/katajainen.c \
    external/zopfli/src/zopfli/lz77.c \
    external/zopfli/src/zopfli/squeeze.c \
    external/zopfli/src/zopfli/tree.c \
    external/zopfli/src/zopfli/util.c \
    external/zopfli/src/zopfli/zlib_container.c \
    external/zopfli/src/zopfli/zopfli_lib.c
LIBZOPFLI_OBJ = $(patsubst %.c,$(OBJ)/%.o,$(LIBZOPFLI_SRC))

LIBZ_SRC = \
    external/zlib/adler32.c \
    external/zlib/compress.c \
    external/zlib/crc32.c \
    external/zlib/deflate.c \
    external/zlib/gzclose.c \
    external/zlib/gzlib.c \
    external/zlib/gzread.c \
    external/zlib/gzwrite.c \
    external/zlib/infback.c \
    external/zlib/inflate.c \
    external/zlib/inftrees.c \
    external/zlib/inffast.c \
    external/zlib/trees.c \
    external/zlib/uncompr.c \
    external/zlib/zutil.c
LIBZ_OBJ = $(patsubst %.c,$(OBJ)/%.o,$(LIBZ_SRC))

LIBFDT_SRC = \
    external/libfdt/fdt.c \
    external/libfdt/fdt_addresses.c \
    external/libfdt/fdt_empty_tree.c \
    external/libfdt/fdt_overlay.c \
    external/libfdt/fdt_ro.c \
    external/libfdt/fdt_rw.c \
    external/libfdt/fdt_strerror.c \
    external/libfdt/fdt_sw.c \
    external/libfdt/fdt_wip.c
LIBFDT_OBJ = $(patsubst %.c,$(OBJ)/%.o,$(LIBFDT_SRC))

# libmagiskbase always static

all: $(BIN_RES) $(DLL_RES) $(LIB)/libmagiskbase.a $(SLIB)/libmincrypt.dll $(SLIB)/libz.dll $(SLIB)/liblzma.dll \
     $(SLIB)/libbz2.dll $(SLIB)/liblz4.dll $(SLIB)/libzopfli.dll $(SLIB)/libfdt.dll \
     $(OUT)/magiskboot$E

$(OBJ)/%.res: %.rc
	@mkdir -p `dirname $@`
	@echo -e "  WINDRES   `basename $@`"
	@windres $< -O coff -o $@

$(OBJ)/external/zopfli/%.o: $(TOPDIR)/%.c
	@mkdir -p `dirname $@`
	@echo -e "  CC\t    `basename $@`"
	@$(CC) $(CFLAGS) -Wall -Werror -Wno-unused -Wno-unused-parameter $(INCLUDES) -c $< -o $@

$(OBJ)/external/lzma/%.o: $(TOPDIR)/external/xz/%.c
	@mkdir -p `dirname $@`
	@echo -e "  CC\t    `basename $@`"
	@$(CC) $(CFLAGS) -DHAVE_CONFIG_H -Wno-implicit-function-declaration $(INCLUDES) $(LIBLZMA_INCLUDES) -c $< -o $@

$(OBJ)/%.o: $(TOPDIR)/%.c
	@mkdir -p `dirname $@`
	@echo -e "  CC\t    `basename $@`"
	@$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

$(OBJ)/magiskboot/%.o: %.cpp
	@mkdir -p `dirname $@`
	@echo -e "  CXX\t    `basename $@`"
	@$(CXX) -static $(CXXFLAGS) $(INCLUDES) -c $< -o $@

$(OBJ)/%.o: %.cpp
	@mkdir -p `dirname $@`
	@echo -e "  CXX\t    `basename $@`"
	@$(CXX) -static $(CXXFLAGS) $(INCLUDES) -c $< -o $@

MAGISKBOOT_LD := $(LIB)/libmincrypt.a $(LIB)/liblzma.a $(LIB)/libbz2.a \
	     $(LIB)/liblz4.a $(LIB)/libzopfli.a $(LIB)/libfdt.a $(LIB)/libz.a
ifeq ($(STATIC), 0)
override MAGISKBOOT_LD := $(shell echo $(MAGISKBOOT_LD) | sed "s@\(obj/lib/\)lib\(\w\+\)\.a@\1shared/svb\2\.dll@g")
endif
$(OUT)/magiskboot$E: $(MAGISKBOOT_OBJ) $(LIB)/libmagiskbase.a $(MAGISKBOOT_LD)
	@mkdir -p `dirname $@`
	@echo -e "  LD\t    `basename $@`"
	@$(CXX) $(CXXFLAGS) $^ -o $@ -static $(LDFLAGS) $(BIN_RES)
	@echo -e "  STRIP     `basename $@`"
	@$(STRIP) $(STRIPFLAGS) $@

$(LIB)/libmagiskbase.a: $(LIBBASE_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "  AR\t    `basename $@`"
	@$(AR) $(ARFLAGS) $@ $^

$(SLIB)/lib%.dll: $(LIB)/lib%.a
	@mkdir -p `dirname $@`
	@echo -e "  LD\t    `basename $@`"
	@$(LD) -shared -o $(SLIB)/svb$*.dll \
	    -Wl,--export-all-symbols \
	    -Wl,--enable-auto-import \
	    -Wl,--out-implib=$(LIB)/lib$*.dll.a \
	    -Wl,--whole-archive $(LIB)/lib$*.a \
	    -Wl,--no-whole-archive $(DLL_RES)

$(LIB)/libmincrypt.a: $(LIBMINCRYPT_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "  AR\t    `basename $@`"
	@$(AR) $(ARFLAGS) $@ $^

$(LIB)/liblzma.a: $(LIBLZMA_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "  AR\t    `basename $@`"
	@$(AR) $(ARFLAGS) $@ $^

$(LIB)/libbz2.a: $(LIBBZ2_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "  AR\t    `basename $@`"
	@$(AR) $(ARFLAGS) $@ $^

$(LIB)/liblz4.a: $(LIBLZ4_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "  AR\t    `basename $@`"
	@$(AR) $(ARFLAGS) $@ $^

$(LIB)/libzopfli.a: $(LIBZOPFLI_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "  AR\t    `basename $@`"
	@$(AR) $(ARFLAGS) $@ $^

$(LIB)/libz.a: $(LIBZ_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "  AR\t    `basename $@`"
	@$(AR) $(ARFLAGS) $@ $^

$(LIB)/libfdt.a: $(LIBFDT_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "  AR\t    `basename $@`"
	@$(AR) $(ARFLAGS) $@ $^
