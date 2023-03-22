# env controlled
DEBUG ?= 0
CROSS_COMPILE ?=
SH ?= sh

# Build configuration (static only, shared are broken)
override TOPDIR := $(shell cygpath -m $(shell pwd))
override STATIC := 1
override SVB_MINGW := 1
override SVB_FLAGS := -DSVB_WIN32 -DANDROID
override BUILD_FLAGS := -fno-exceptions -fdiagnostics-absolute-paths -Wno-deprecated-non-prototype -DHOST
override BUILD_EXTRAS := 0
override BIN_EXT := .exe
override LIB_EXT := .a

ifeq ($(STATIC),0)
$(warning WARNING: Host libraries are statically linked)
override LIB_EXT := .dll
endif

ifeq ($(DEBUG),1)
override BUILD_FLAGS += -ggdb -ffunction-sections -Wall -Wextra -Wpedantic -Wconversion-null -Wno-gnu-include-next
override SVB_FLAGS += -DSVB_DEBUG
else
override BUILD_FLAGS += -Oz
endif
override LDFLAGS := -Wl,-gc-sections

ifeq ($(SVB_MINGW),1)
override SVB_FLAGS += -DSVB_MINGW -DHAVE_LIB_NT_H -I$(TOPDIR)/libnt/include
all:: svbnt magiskboot
else
all:: print_info init_out res magiskboot
endif

override CC := $(CROSS_COMPILE)clang
override CFLAGS := $(CFLAGS) $(BUILD_FLAGS) $(SVB_FLAGS)
override CXX := $(CROSS_COMPILE)clang++
override CXXSTD := c++17
override CXXLIB := libc++
override CXXFLAGS := $(CXXFLAGS) -std=$(CXXSTD) -stdlib=$(CXXLIB) $(BUILD_FLAGS) $(SVB_FLAGS)
# LD is set for shared libs
ifeq ($(STATIC),0)
override LD := $(CROSS_COMPILE)clang $(BUILD_FLAGS)
override LDXX := $(CROSS_COMPILE)clang++ -std=$(CXXSTD) -stdlib=$(CXXLIB) $(BUILD_FLAGS) -static-libstdc++
#override LDFLAGS += -Wl,--large-address-aware
endif
override STRIP_CMD := $(CROSS_COMPILE)strip
override STRIPFLAGS := $(STRIPFLAGS) --strip-all -R .comment -R .gnu.version --strip-unneeded
override AR := $(CROSS_COMPILE)ar
override ARFLAGS := rcsD

override DEPLOY := $(TOPDIR)/build
override OUT := $(TOPDIR)/out
override SRP := $(OUT)
override OBJ := $(OUT)/obj
override LIB := $(OBJ)/lib
override SLIB := $(LIB)/shared
override LIB_OUT := $(LIB)
ifeq ($(STATIC),0)
override LIB_OUT := $(SLIB)
endif

override STRIP := $(SH) $(TOPDIR)/scripts/strip.sh
override MKDIR := $(SH) $(TOPDIR)/scripts/mkdir.sh

override BIN_RES := $(OBJ)/bin.res
override DLL_RES := $(OBJ)/dll.res

ifeq ($(SVB_MINGW),1)
override LIBS := -lWs2_32 $(LIB)/libnt.a -limagehlp -lpthread
endif

override NTLIB := libnt

override GNUMAKEFLAGS += --output-sync=line --no-print-directory
override MAKEFLAGS := -$(MAKEFLAGS) $(GNUMAKEFLAGS) --warn-undefined-variables

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
    external/lzma/common/tuklib_cpucores.c \
    external/lzma/common/tuklib_exit.c \
    external/lzma/common/tuklib_mbstr_fw.c \
    external/lzma/common/tuklib_mbstr_width.c \
    external/lzma/common/tuklib_open_stdxxx.c \
    external/lzma/common/tuklib_physmem.c \
    external/lzma/common/tuklib_progname.c \
    external/lzma/liblzma/check/check.c \
    external/lzma/liblzma/check/crc32_fast.c \
    external/lzma/liblzma/check/crc32_table.c \
    external/lzma/liblzma/check/crc64_fast.c \
    external/lzma/liblzma/check/crc64_table.c \
    external/lzma/liblzma/check/sha256.c \
    external/lzma/liblzma/common/alone_decoder.c \
    external/lzma/liblzma/common/alone_encoder.c \
    external/lzma/liblzma/common/auto_decoder.c \
    external/lzma/liblzma/common/block_buffer_decoder.c \
    external/lzma/liblzma/common/block_buffer_encoder.c \
    external/lzma/liblzma/common/block_decoder.c \
    external/lzma/liblzma/common/block_encoder.c \
    external/lzma/liblzma/common/block_header_decoder.c \
    external/lzma/liblzma/common/block_header_encoder.c \
    external/lzma/liblzma/common/block_util.c \
    external/lzma/liblzma/common/common.c \
    external/lzma/liblzma/common/easy_buffer_encoder.c \
    external/lzma/liblzma/common/easy_decoder_memusage.c \
    external/lzma/liblzma/common/easy_encoder.c \
    external/lzma/liblzma/common/easy_encoder_memusage.c \
    external/lzma/liblzma/common/easy_preset.c \
    external/lzma/liblzma/common/filter_buffer_decoder.c \
    external/lzma/liblzma/common/filter_buffer_encoder.c \
    external/lzma/liblzma/common/filter_common.c \
    external/lzma/liblzma/common/filter_decoder.c \
    external/lzma/liblzma/common/filter_encoder.c \
    external/lzma/liblzma/common/filter_flags_decoder.c \
    external/lzma/liblzma/common/filter_flags_encoder.c \
    external/lzma/liblzma/common/hardware_cputhreads.c \
    external/lzma/liblzma/common/hardware_physmem.c \
    external/lzma/liblzma/common/index.c \
    external/lzma/liblzma/common/index_decoder.c \
    external/lzma/liblzma/common/index_encoder.c \
    external/lzma/liblzma/common/index_hash.c \
    external/lzma/liblzma/common/outqueue.c \
    external/lzma/liblzma/common/stream_buffer_decoder.c \
    external/lzma/liblzma/common/stream_buffer_encoder.c \
    external/lzma/liblzma/common/stream_decoder.c \
    external/lzma/liblzma/common/stream_encoder.c \
    external/lzma/liblzma/common/stream_encoder_mt.c \
    external/lzma/liblzma/common/stream_flags_common.c \
    external/lzma/liblzma/common/stream_flags_decoder.c \
    external/lzma/liblzma/common/stream_flags_encoder.c \
    external/lzma/liblzma/common/vli_decoder.c \
    external/lzma/liblzma/common/vli_encoder.c \
    external/lzma/liblzma/common/vli_size.c \
    external/lzma/liblzma/delta/delta_common.c \
    external/lzma/liblzma/delta/delta_decoder.c \
    external/lzma/liblzma/delta/delta_encoder.c \
    external/lzma/liblzma/lz/lz_decoder.c \
    external/lzma/liblzma/lz/lz_encoder.c \
    external/lzma/liblzma/lz/lz_encoder_mf.c \
    external/lzma/liblzma/lzma/fastpos_table.c \
    external/lzma/liblzma/lzma/lzma2_decoder.c \
    external/lzma/liblzma/lzma/lzma2_encoder.c \
    external/lzma/liblzma/lzma/lzma_decoder.c \
    external/lzma/liblzma/lzma/lzma_encoder.c \
    external/lzma/liblzma/lzma/lzma_encoder_optimum_fast.c \
    external/lzma/liblzma/lzma/lzma_encoder_optimum_normal.c \
    external/lzma/liblzma/lzma/lzma_encoder_presets.c \
    external/lzma/liblzma/rangecoder/price_table.c \
    external/lzma/liblzma/simple/arm.c \
    external/lzma/liblzma/simple/armthumb.c \
    external/lzma/liblzma/simple/ia64.c \
    external/lzma/liblzma/simple/powerpc.c \
    external/lzma/liblzma/simple/simple_coder.c \
    external/lzma/liblzma/simple/simple_decoder.c \
    external/lzma/liblzma/simple/simple_encoder.c \
    external/lzma/liblzma/simple/sparc.c \
    external/lzma/liblzma/simple/x86.c
LIBLZMA_INCLUDES = \
    -I$(TOPDIR)/external/xz_config \
    -I$(TOPDIR)/external/xz/common \
    -I$(TOPDIR)/external/xz/liblzma/api \
    -I$(TOPDIR)/external/xz/liblzma/check \
    -I$(TOPDIR)/external/xz/liblzma/common \
    -I$(TOPDIR)/external/xz/liblzma/delta \
    -I$(TOPDIR)/external/xz/liblzma/lz \
    -I$(TOPDIR)/external/xz/liblzma/lzma \
    -I$(TOPDIR)/external/xz/liblzma/rangecoder \
    -I$(TOPDIR)/external/xz/liblzma/simple \
    -I$(TOPDIR)/external/xz/liblzma
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
    external/lz4/lz4.c \
    external/lz4/lz4frame.c \
    external/lz4/lz4hc.c \
    external/lz4/xxhash.c
LIBLZ4_OBJ = $(patsubst %.c,$(OBJ)/%.o,$(LIBLZ4_SRC))

LIBZOPFLI_SRC = \
    external/zopfli/blocksplitter.c \
    external/zopfli/cache.c \
    external/zopfli/deflate.c \
    external/zopfli/gzip_container.c \
    external/zopfli/hash.c \
    external/zopfli/katajainen.c \
    external/zopfli/lz77.c \
    external/zopfli/squeeze.c \
    external/zopfli/tree.c \
    external/zopfli/util.c \
    external/zopfli/zlib_container.c \
    external/zopfli/zopfli_lib.c
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

BUILD_SHARED := \
	$(SLIB)/svbmincrypt.dll \
	$(SLIB)/svbzopfli.dll \
	$(SLIB)/svbbase.dll \
	$(SLIB)/svblzma.dll \
	$(SLIB)/svblz4.dll \
	$(SLIB)/svbfdt.dll \
	$(SLIB)/svbbz2.dll \
	$(SLIB)/svbz.dll
BUILD_FILES := $(SRP)/magiskboot$(BIN_EXT)

BUILD_EXTRA :=

ifeq (1,$(STATIC))
override BUILD_SHARED :=
endif

ifeq (1,$(BUILD_EXTRAS))
override BUILD_FILES := $(BUILD_FILES) $(BUILD_EXTRAS)
endif

override MAKEFLAGS += -rsR

export TOPDIR DEBUG STATIC SVB_MINGW BUILD_FILES CROSS_COMPILE AR LIBS SVB_FLAGS CC CFLAGS CXX CXXSTD CXXLIB CXXFLAGS \
	LD LDXX LDFLAGS STRIP STRIP_CMD STRIPFLAGS AR ARFLAGS LIBS DEPLOY OUT OBJ LIB SRP SLIB BIN_RES DLL_RES BIN_EXT LIB_EXT LIB_OUT MKDIR \
	GNUMAKEFLAGS

.PHONY: all

print_info:
	$(info INFO: CXX STD VERSION '$(CXXSTD)')
	$(info INFO: CXX STD LIB '$(CXXLIB)')
	$(info INFO: CC '$(CC) $(CFLAGS)')
	$(info INFO: CXX '$(CXX) $(CXXFLAGS)')
	$(info INFO: LD '$(CXX) $(CXXFLAGS) $(LDFLAGS) $(BIN_RES) $(LIBS)')
	$(info INFO: AR '$(AR) $(ARFLAGS)')
	$(info INFO: STRIP '$(STRIP) $(STRIPFLAGS)')

init_out:
	@$(MKDIR) -p $(OUT)
	@$(MKDIR) -p $(OBJ)
	@$(MKDIR) -p $(LIB)
	@if [[ $(STATIC) -eq 0 ]]; then \
		$(MKDIR) -p $(SLIB); \
	fi

res: $(BIN_RES) $(DLL_RES)

svbnt: init_out print_info res
	@$(MAKE) $(MAKEFLAGS) -C $(NTLIB)

$(OBJ)/%.res: %.rc
	@echo -e "  WINDRES   `basename $@`"
	@windres --input=$< --output-format=coff --output=$@

clean:
	@echo -e "  RM\t    obj"
	@rm -rf $(OBJ)
	@echo -e "  RM\t    bin"
	@rm -rf $(OUT)

override INCLUDES := \
    -Iinclude \
    -I$(TOPDIR)/external \
    -I$(TOPDIR)/external/libfdt \
    -I$(TOPDIR)/external/mincrypt/include \
    -Imagiskbase/include \
    -I$(TOPDIR)/external/bzip2 \
    -I$(TOPDIR)/external/xz/liblzma/api \
    -I$(TOPDIR)/external/zlib \
    -I$(TOPDIR)/external/lz4

# libmagiskbase always static
extlib: $(LIB_OUT)/libmincrypt$(LIB_EXT) $(LIB_OUT)/libz$(LIB_EXT) $(LIB_OUT)/liblzma$(LIB_EXT) \
		$(LIB_OUT)/libbz2$(LIB_EXT) $(LIB_OUT)/liblz4$(LIB_EXT) $(LIB_OUT)/libzopfli$(LIB_EXT) $(LIB_OUT)/libfdt$(LIB_EXT)

magiskboot: extlib $(LIB)/libmagiskbase.a $(OUT)/magiskboot$(BIN_EXT)

$(OBJ)/external/zopfli/%.o: $(TOPDIR)/%.c
	@$(MKDIR) -p `dirname $@`
	@echo -e "  CC\t    `basename $@`"
	@$(CC) $(CFLAGS) -Wall -Werror -Wno-unused -Wno-unused-parameter $(INCLUDES) -c $< -o $@

$(OBJ)/external/lzma/%.o: $(TOPDIR)/external/xz/%.c
	@$(MKDIR) -p `dirname $@`
	@echo -e "  CC\t    `basename $@`"
	@$(CC) $(CFLAGS) -DHAVE_CONFIG_H -Wno-implicit-function-declaration $(INCLUDES) $(LIBLZMA_INCLUDES) -c $< -o $@

$(OBJ)/%.o: $(TOPDIR)/%.c
	@$(MKDIR) -p `dirname $@`
	@echo -e "  CC\t    `basename $@`"
	@$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

$(OBJ)/%.o: %.cpp
	@$(MKDIR) -p `dirname $@`
	@echo -e "  CXX\t    `basename $@`"
	@$(CXX) -static $(CXXFLAGS) $(INCLUDES) -c $< -o $@

$(OBJ)/magiskboot/%.o: %.cpp
	@$(MKDIR) -p `dirname $@`
	@echo -e "  CXX\t    `basename $@`"
	@$(CXX) -static $(CXXFLAGS) $(INCLUDES) -c $< -o $@

MAGISKBOOT_LD := $(LIB)/libmincrypt.a $(LIB)/liblzma.a $(LIB)/libbz2.a \
				 $(LIB)/liblz4.a $(LIB)/libzopfli.a $(LIB)/libfdt.a $(LIB)/libz.a
ifeq ($(STATIC),0)
override MAGISKBOOT_LD := $(shell echo $(MAGISKBOOT_LD) | sed "s@\(obj/lib/\)lib\(\w\+\)\.a@\1shared/svb\2\.dll@g")
endif
$(OUT)/magiskboot$(BIN_EXT): $(MAGISKBOOT_OBJ) $(LIB)/libmagiskbase.a $(MAGISKBOOT_LD)
	@$(MKDIR) -p `dirname $@`
	@echo -e "  LD\t    `basename $@`"
	@$(CXX) $(CXXFLAGS) $^ -o $@ -static $(LDFLAGS) $(BIN_RES) $(LIBS)
	@$(STRIP) $(STRIPFLAGS) $@

$(LIB)/libmagiskbase.a: $(LIBBASE_OBJ)
	@$(MKDIR) -p `dirname $@`
	@echo -e "  AR\t    `basename $@`"
	@$(AR) $(ARFLAGS) $@ $^

$(SLIB)/lib%.dll: $(LIB)/lib%.a
	@echo -e "  LD\t    `basename $@`"
	@$(LD) -shared -o $(SLIB)/svb$*.dll \
	    -Wl,--export-all-symbols \
	    -Wl,--enable-auto-import \
	    -Wl,--whole-archive $^ \
	    -Wl,--no-whole-archive -lpthread $(DLL_RES)

$(LIB)/libmincrypt.a: $(LIBMINCRYPT_OBJ)
	@$(MKDIR) -p `dirname $@`
	@echo -e "  AR\t    `basename $@`"
	@$(AR) $(ARFLAGS) $@ $^

$(LIB)/liblzma.a: $(LIBLZMA_OBJ)
	@$(MKDIR) -p `dirname $@`
	@echo -e "  AR\t    `basename $@`"
	@$(AR) $(ARFLAGS) $@ $^

$(LIB)/libbz2.a: $(LIBBZ2_OBJ)
	@$(MKDIR) -p `dirname $@`
	@echo -e "  AR\t    `basename $@`"
	@$(AR) $(ARFLAGS) $@ $^

$(LIB)/liblz4.a: $(LIBLZ4_OBJ)
	@$(MKDIR) -p `dirname $@`
	@echo -e "  AR\t    `basename $@`"
	@$(AR) $(ARFLAGS) $@ $^

$(LIB)/libzopfli.a: $(LIBZOPFLI_OBJ)
	@$(MKDIR) -p `dirname $@`
	@echo -e "  AR\t    `basename $@`"
	@$(AR) $(ARFLAGS) $@ $^

$(LIB)/libz.a: $(LIBZ_OBJ)
	@$(MKDIR) -p `dirname $@`
	@echo -e "  AR\t    `basename $@`"
	@$(AR) $(ARFLAGS) $@ $^

$(LIB)/libfdt.a: $(LIBFDT_OBJ)
	@$(MKDIR) -p `dirname $@`
	@echo -e "  AR\t    `basename $@`"
	@$(AR) $(ARFLAGS) $@ $^