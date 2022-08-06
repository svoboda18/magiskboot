# MagiskBoot - Boot Image Modification Tool
The most complete tool for unpacking and repacking Android boot images.

**Note**: This is a minimal (dirty) copy of topjohnwu's [MagiskBoot](https://github.com/topjohnwu/Magisk/tree/master/native/src/boot).

## Documentation
- [MagiskBoot Documentation](https://topjohnwu.github.io/Magisk/tools.html#magiskboot)
## Build
- Using cygwin64 environment with `clang-8` and `libc++8`, run `make` command. (`magiskboot.exe` will appear in the `out` folder).
- if built a non-static variant, all DLLs in `out/obj/lib/shared` must be present in your PATH for successful execution. 

## What's changed:
- `cpio` action `extract` with no paramaters extracts to `ramdisk` folder in current directory.
   * it creates `cpio` file to allow mode changes in Windows (with `sync` or `pack`)
- new `cpio` action `sync` that synchronize incpio entries with `ramdisk` directory (as new cpio). Any changes will be captured and dumped to incpio.
   * Reads each entry mode from `cpio` config.
- new `cpio` action `pack` as follows: `cpio pack [-c <config>] <infolder> <outcpio>`
   * Creates `<outcpio>` from `<infolder>` entries, each entry mode is read from `<config>` (`cpio` if undefined).

## For Windows
- There's alot of unexpected/undefined behaviours that needs to be addressed.
- Tested and working operations are limited.