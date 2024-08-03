module dirsplitter.split;

import std.stdio : writeln;
import std.file : exists, mkdir, rename, dirEntries, DirEntry, SpanMode, isFile, getSize, FileException;
import std.path : baseName, chainPath, buildNormalizedPath;
import std.array : byPair;
import std.string : empty;
import std.format : format;

void splitDir(string dir, long maxSize, string prefix)
{
    writeln("\nSplitting Directory...\n");

    ulong[int] tracker;
    auto currentPart = 1;
    auto filesMoved = 0;
    auto failedOps = 0;

    foreach (DirEntry de; dirEntries(dir, SpanMode.shallow))
    {
        if (!de.isFile)
            continue;

        bool decrementIfFailed = false;
        try
        {
            ulong size = getSize(de);
            ulong currentSize = tracker.get(currentPart, 0UL);
            if (currentSize > 0UL && currentSize + size > maxSize)
            {
                currentPart++;
                currentSize = 0UL;
                decrementIfFailed = true;
            }
            tracker[currentPart] = currentSize + size;
        }
        catch (FileException e)
        {
            writeln("failed to get filesize: ", e);
        }

        try
        {
            string partNum = format("part%d", currentPart);
            auto partDir = buildNormalizedPath(dir, partNum);
            if (!partDir.exists)
                partDir.mkdir;
            rename(de.name, chainPath(partDir, baseName(buildNormalizedPath(de.name))));
            filesMoved++;
        }
        catch (FileException e)
        {
            writeln("failed to move file : ", e);
            failedOps++;
            tracker[currentPart] -= getSize(de);
            if (decrementIfFailed)
                currentPart--;
        }
    }
    if (filesMoved == 0)
        currentPart = 0;

    writeln("Results:");
    writeln("Files Moved: ", filesMoved);
    writeln("Failed Operations: ", failedOps);

    foreach (pair; tracker.byPair)
    {
        auto mb = pair.value / (1024 ^^ 2);
        writeln("Part", pair.key, " : ", mb, "MB");
    }

    if (currentPart > 0 && !prefix.empty)
    {
        if (currentPart == 1)
            writeln(i`Tar Command : tar -cf "$(prefix)part1.tar" "part1"; done`);
        else
            writeln(
                i`Tar Command : for n in {1 .. $(currentPart)}; do tar - cf "${prefix}part$n.tar" "part$n"; done`);
    }
}
