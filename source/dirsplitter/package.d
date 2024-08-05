module dirsplitter;

import dirsplitter.reverse;
import dirsplitter.split;

import std.stdio : writeln;
import std.conv : to;
import commandr;

immutable GbTransform = 1024 ^^ 3;


void main(string[] args)
{
    auto appArgs = new Program("dirsplitter", "1.0.1")
        .summary("Split Directories")
        .author("Sergei Giniatulin gh@cyrusmsk")
        .add(
            new Command("split")
                .summary("Split a directory into parts of a given size")
                .add(new Option("m", "max", "Max part size in GB [default: 5.0]")
                    .tag("MAX")
                    .defaultValue("5.0"))
                .add(new Option("d", "dir", "Target directory")
                    .tag("TARGET")
                    .defaultValue("."))
                .add(new Option("p", "prefix", "Prefix for output files of the tar command. eg: myprefix.part1.tar")
                    .tag("PREFIX"))
    )
        .add(
            new Command("reverse")
                .summary("Reverse a split directory")
                .add(new Option("d", "dir", "Target directory")
                        .tag("TARGET")
                        .defaultValue("."))
    )
        .parse(args);

    appArgs
        .on("split", (args) {
            splitDir(args.option("dir"), (args.option("max")
                .to!double * GbTransform).to!long, args.option("prefix"));
        })
        .on("reverse", (args) { reverseSplitDir(args.option("dir")); });
}
