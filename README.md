# vdiff

Multithreaded file differ written in V.

### Usage

```
Usage: vdiff [options] [ARGS]

Description: File differ

The arguments should be exactly 2 in number.

Options:
  -j, --threads <int>       Number of threads to use
  -c, --chunk-size <int>    Chunk size to use
  -h, --help                display this help and exit
  --version                 output version information and exit
```

### Building

Ensure you have [V](https://vlang.io/) installed and added to PATH.

```
git clone https://github.com/dy-tea/vdiff.git
cd vdiff
v -prod .
```
