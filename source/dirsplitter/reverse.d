module dirsplitter.reverse;

import std.file : rename, isFile, isDir,
    DirEntry, dirEntries, SpanMode, exists,
    FileException, mkdirRecurse, rmdirRecurse;
import std.path : relativePath, absolutePath, buildNormalizedPath, dirName, baseName;
import std.regex : matchFirst, regex;
import std.stdio : writeln;

void reverseSplitDir(string dir)
{
    bool[string] partDirToDelete;
    bool shouldDelete = true;

    try
    {
        foreach (DirEntry de; dirEntries(dir, SpanMode.shallow))
        {
            if (de.isDir && matchFirst(de.name, regex(`part\d+$`)))
            {
                auto partDir = de.name;
                partDirToDelete[partDir] = true;
                foreach (f; dirEntries(partDir, SpanMode.depth))
                {
                    if (f.isFile)
                    {
                        auto relPath = relativePath(absolutePath(f), absolutePath(partDir));
                        auto relDir = dirName(relPath);
                        auto newDir = buildNormalizedPath(dir, relDir);
                        if (!exists(newDir))
                            mkdirRecurse(newDir);
                        rename(f.name, buildNormalizedPath(dir, relPath));
                    }
                }
            }
        }
    }
    catch (FileException e)
    {
        writeln("Failed to move file : ", e.message);
        shouldDelete = false;
    }

    if (shouldDelete)
        foreach (part; partDirToDelete.keys)
        {
            try
            {
                rmdirRecurse(part);
            }
            catch (FileException e)
            {
                writeln("Failed to remove folder: ", part, " ", e.message);
            }
        }
}
