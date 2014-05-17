module dash.cli.commands;
import dash.cli.project;

import std.getopt;

abstract class Command
{
    string name;
    string[] argPattern;

    abstract void prepare( string[] );
    abstract void execute( Project );
}

class CreateCommand : Command
{
    bool leaveGitkeep = false;

    this()
    {
        name = "create";
        argPattern = [ "[name]" ];
    }

    override void prepare( string[] args )
    {
        args.getopt(
            "g|gitkeep", &leaveGitkeep );
    }

    override void execute( Project project )
    {
        import std.file, std.path, std.zip, std.stream;
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
}
