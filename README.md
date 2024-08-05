# dirsplitter-d

Split large directories into parts of a specified maximum size.
This is a D port of dirsplitter tool.


## How to build:

- Clone this git repo  
- Install D : [https://dlang.org/download.html](https://dlang.org/download.html)
- Install dub : [https://dub.pm/getting-started/install/](https://dub.pm/getting-started/install/)
- cd into directory and compile with: 
```bash
dub build -b=release
```

## How to run:

After build or if you downloaded binaries from Releases:
```bash
dirsplitter -h
```

## USAGE:

```text
USAGE
  $ dirsplitter [-h] [--version] split|reverse

FLAGS
  -h, --help                prints help
      --version             prints version

SUBCOMMANDS
  split                     Split a directory into parts of a given size
  reverse                   Reverse a split directory
```

## SPLIT USAGE:

```text
dirsplitter split: Split a directory into parts of a given size

USAGE
  $ dirsplitter split [-h] [-m MAX] [-d TARGET] [-p PREFIX] 

FLAGS
  -h, --help                prints help

OPTIONS
  -m, --max MAX             Max part size in GB [default: 5.0]
  -d, --dir TARGET          Target directory
  -p, --prefix PREFIX       Prefix for output files of the tar command. eg: myprefix.part1.tar
```

### example:

```bash
dirsplitter split --max 0.5 -d ./mylarge2GBdirectory

This will yield the following directory structure:

📂mylarge2GBdirectory
 |- 📂part1
 |- 📂part2
 |- 📂part3
 |- 📂part4

with each part being a maximum of 500MB in size.
```

Undo splitting

```text
dirsplitter reverse: Reverse a split directory

USAGE
  $ dirsplitter reverse [-h] [-d TARGET] 

FLAGS
  -h, --help                prints help

OPTIONS
  -d, --dir TARGET          Target directory
```

Example:
```bash
dirsplitter reverse -d ./mylarge2GBdirectory
```

# References

[Go version](https://github.com/jinyus/dirsplitter)
Other versions are available in the repo of the original author as well (Python, F#, Nim, Crystal, Dart)