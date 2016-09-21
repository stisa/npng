# Converted from Pascal

## Interface to the zlib http://www.zlib.net/ compression library.
# Taken from https://github.com/nim-lang/zip/blob/master/zip/zlib.nim
# License: https://github.com/nim-lang/zip/blob/master/LICENSE
#[
  The MIT License (MIT)
  Copyright (c) 2015 

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restricòtion, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
]#

when defined(windows):
  const libz = "zlib1.dll"
elif defined(macosx):
  const libz = "libz.dylib"
else:
  const libz = "libz.so.1"

type
  Uint* = int32
  Ulong* = int
  Ulongf* = int
  Pulongf* = ptr Ulongf
  ZOffT* = int32
  Pbyte* = cstring
  Pbytef* = cstring
  Allocfunc* = proc (p: pointer, items: Uint, size: Uint): pointer{.cdecl.}
  FreeFunc* = proc (p: pointer, address: pointer){.cdecl.}
  InternalState*{.final, pure.} = object 
  PInternalState* = ptr InternalState
  ZStream*{.final, pure.} = object 
    nextIn*: Pbytef
    availIn*: Uint
    totalIn*: Ulong
    nextOut*: Pbytef
    availOut*: Uint
    totalOut*: Ulong
    msg*: Pbytef
    state*: PInternalState
    zalloc*: Allocfunc
    zfree*: FreeFunc
    opaque*: pointer
    dataType*: int32
    adler*: Ulong
    reserved*: Ulong

  ZStreamRec* = ZStream
  PZstream* = ptr ZStream
  GzFile* = pointer
{.deprecated: [TInternalState: InternalState, TAllocfunc: Allocfunc,
              TFreeFunc: FreeFunc, TZStream: ZStream, TZStreamRec: ZStreamRec].}

const 
  Z_NO_FLUSH* = 0
  Z_PARTIAL_FLUSH* = 1
  Z_SYNC_FLUSH* = 2
  Z_FULL_FLUSH* = 3
  Z_FINISH* = 4
  Z_OK* = 0
  Z_STREAM_END* = 1
  Z_NEED_DICT* = 2
  Z_ERRNO* = -1
  Z_STREAM_ERROR* = -2
  Z_DATA_ERROR* = -3
  Z_MEM_ERROR* = -4
  Z_BUF_ERROR* = -5
  Z_VERSION_ERROR* = -6
  Z_NO_COMPRESSION* = 0
  Z_BEST_SPEED* = 1
  Z_BEST_COMPRESSION* = 9
  Z_DEFAULT_COMPRESSION* = -1
  Z_FILTERED* = 1
  Z_HUFFMAN_ONLY* = 2
  Z_DEFAULT_STRATEGY* = 0
  Z_BINARY* = 0
  Z_ASCII* = 1
  Z_UNKNOWN* = 2
  Z_DEFLATED* = 8
  Z_NULL* = 0
proc compress*(dest: Pbytef, destLen: Pulongf, source: Pbytef, sourceLen: Ulong): cint{.
    cdecl, dynlib: libz, importc: "compress".}
proc compressBound*(sourceLen: Ulong): Ulong {.cdecl, dynlib: libz, importc.}
proc adler32*(adler: Ulong, buf: Pbytef, length: Uint): Ulong{.cdecl, 
    dynlib: libz, importc: "adler32".}
  ## **Warning**: Adler-32 requires at least a few hundred bytes to get rolling.
proc crc32*(crc: Ulong, buf: Pbytef, length: Uint): Ulong{.cdecl, dynlib: libz, 
    importc: "crc32".}
proc getCrcTable*(): pointer{.cdecl, dynlib: libz, importc: "get_crc_table".}
