module dash.cli.utility;

import std.path;

auto relToGame( String )( String path, string gameDir )
{
    return path.absolutePath().relativePath( gameDir ).buildNormalizedPath();
}
