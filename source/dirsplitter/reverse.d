module dirsplitter.reverse;

import std.file : rename, isFile, isDir, DirEntry, dirEntries, SpanMode, FileException, rmdir;
import std.path : chainPath, buildNormalizedPath, baseName;
import std.regex : matchFirst, regex;
import std.stdio : writeln;

void reverseSplitDir(string dir)
{
    string[] partDirToDelete;
    bool shouldDelete = true;

    try
    {
        foreach (DirEntry de; dirEntries(dir, SpanMode.depth))
        {
            if (de.isDir && matchFirst(de.name, regex(`part\d+`)))
            {
                auto partDir = de.name;
                partDirToDelete ~= partDir;
                foreach (f; dirEntries(partDir, SpanMode.depth))
                {
                    if (f.isFile)
                    {
                        auto newPath = chainPath(buildNormalizedPath(dir), baseName(f));
                        rename(f, newPath);
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
        foreach (part; partDirToDelete)
        {
            try
            {
                rmdir(part);
            }
            catch (FileException e)
            {
                writeln("Failed to remove folder: ", part, " ", e.message);
            }
        }
}
