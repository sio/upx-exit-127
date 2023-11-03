>
> [This issue](https://github.com/upx/upx/issues/721)
> was fixed in upx 4.2.1, many thanks to
> [@jreiser](https://github.com/jreiser)!
>

# Packed binaries crash with exit 127 on linux/amd64

I've stumbled upon a reproducible crash of upx-packed binaries in isolated
Linux namespace. At first I though that this is related to recently [fixed
error] but that turned out not to be the case:

[fixed error]: https://github.com/upx/upx/pull/716

- It's not caused by LZMA (both NRV2E_LE32 and LZMA compression produce
  failing binaries)
- It's reproducible with latest `devel4` artifacts

[This repo](https://github.com/sio/upx-exit-127) contains minimal reproducible
example of C hello world program that crashes after being packed by upx when
being executed under
[`unshare`](https://manpages.debian.org/bookworm/util-linux/unshare.1.en.html).
Similar to [previous issue][fixed error] the program writes `/proc/self/exe`
to stderr before returning exit code 127.

Execute `make demo` to run binaries built by me, or `make clean demo` to
rebuild binaries on your machine before executing (requires C compiler).

I first noticed this failure with UPX 3.96 and was able to reproduce it with
UPX 4.2.0-git-c9550b48d8e7 (current devel4). I'm running Debian Bullseye
(Linux kernel 5.10).

Here is sample output of `make clean demo` (edited to enable syntax
highlighting on GitHub):

```console
$ rm -f demo-unpacked demo-packed
$ cc demo.c -o demo-unpacked -static
$ upx -V
upx 4.2.0-git-c9550b48d8e7
UCL data compression library 1.03
zlib data compression library 1.3.0.1-motley
LZMA SDK version 4.43
doctest C++ testing framework version 2.4.11
Copyright (C) 1996-2023 Markus Franz Xaver Johannes Oberhumer
Copyright (C) 1996-2023 Laszlo Molnar
Copyright (C) 2000-2023 John F. Reiser
Copyright (C) 2002-2023 Jens Medoch
Copyright (C) 1995-2023 Jean-loup Gailly and Mark Adler
Copyright (C) 1999-2006 Igor Pavlov
Copyright (C) 2016-2023 Viktor Kirilov
UPX comes with ABSOLUTELY NO WARRANTY; for details type 'upx -L'.
$ upx demo-unpacked -o demo-packed
                       Ultimate Packer for eXecutables
                          Copyright (C) 1996 - 2023
UPX git-c9550b  Markus Oberhumer, Laszlo Molnar & John Reiser    Oct 5th 2023

        File size         Ratio      Format      Name
   --------------------   ------   -----------   -----------
    809800 ->    315472   38.96%   linux/amd64   demo-packed

Packed 1 file.

WARNING: this is an unstable beta version - use for testing only! Really.
$ touch demo-packed
$ upx --fileinfo demo-packed
                       Ultimate Packer for eXecutables
                          Copyright (C) 1996 - 2023
UPX git-c9550b  Markus Oberhumer, Laszlo Molnar & John Reiser    Oct 5th 2023

demo-packed [amd64-linux.elf, linux/amd64]
    315472 bytes, compressed by UPX 14, method 8, level 7, filter 0x49/0x1d

WARNING: this is an unstable beta version - use for testing only! Really.
$ ./demo-unpacked
It works!
$ ./demo-packed
It works!
$ unshare --map-root-user unshare --root=. ./demo-unpacked
It works!
$ unshare --map-root-user unshare --root=. ./demo-packed
/proc/self/exemake: *** [Makefile:6: demo] Error 127
```

Unfortunately I lack the fine skills @kevingosse demonstrated when
troubleshooting previous similar failure, so I will need your guidance if any
further input is needed.
