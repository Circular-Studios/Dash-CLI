module dash.cli.create;
import dash.cli.utility;

import std.algorithm, std.file, std.path, std.zip, std.stream;

void createProject( string gameDir )
{
    // If the project folder doesn't exist, create it.
    if( !gameDir.exists() )
        gameDir.mkdirRecurse();

    // Unzip empty game to new folder.
    auto zr = new ZipArchive( thisExePath.dirName.buildNormalizedPath( "empty-game.zip" ).read() );

    // Extract the empty-game.zip template.
    foreach( ArchiveMember de; zr.directory )
    {
        // Ignore folders.
        if( de.name[ $-1 ].among( '/', '\\' ) )
            continue;

        // Make sure folder exists.
        auto absPath = de.name.inGame( gameDir );
        if( !absPath.dirName.exists )
            absPath.dirName.mkdirRecurse();

        // Extract the file.
        auto f = new File( absPath, FileMode.OutNew );
        zr.expand( de );
        f.write( de.expandedData );
        f.flush();
        f.close();
    }
}
