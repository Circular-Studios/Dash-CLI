module dash.cli.create;
import dash.cli.utility;

import std.file, std.path;

void createProject( string gameDir )
{
    // If the project folder doesn't exist, create it.
    if( !gameDir.exists() )
        gameDir.mkdirRecurse();

    // Unzip empty game to new folder.
}
