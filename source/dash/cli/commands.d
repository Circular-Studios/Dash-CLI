module dash.cli.commands;
import dash.cli.project;
import dash.cli.utility;

import std.getopt, std.algorithm, std.string, std.array, std.file, std.path;
import io = std.stdio;

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

    void opCall( Project project )
    {
        execute( project );
    }

    override void execute( Project project )
    {
        import std.file, std.path, std.zip, std.stream, std.algorithm;
        // If the project folder doesn't exist, create it.
        if( !project.directory.exists() )
            project.directory.mkdirRecurse();

        // Unzip empty game to new folder.
        auto zr = new ZipArchive( thisExePath.dirName.buildNormalizedPath( "empty-game.zip" ).read() );

        // Extract the empty-game.zip template.
        foreach( ArchiveMember de; zr.directory )
        {
            // Ignore folders.
            if( de.name[ $-1 ].among( '/', '\\' ) )
                continue;

            // Make sure folder exists.
            auto absPath = project.pathOfMember( de.name );
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

class CompressCommand : Command
{
    this()
    {
        name = "compress";
        argPattern = [ "[name]" ];
    }

    override void prepare( string[] args )
    {

    }

    override void execute( Project project )
    {
        import yaml;
        Node content = makeMap();

        enum passThrough( string tag ) = q{
            ctor.addConstructorScalar( "!$tag", ( ref Node node ) { return node.get!string; } );
        }.strip().replace( "$tag", tag );
        auto ctor = new Constructor;
        mixin( passThrough!"Verbosity" );
        mixin( passThrough!"Vector2" );
        mixin( passThrough!"Vector3" );
        mixin( passThrough!"Keyboard" );

        foreach( entry; project.directory.dirEntries( "*.y{a,}ml", SpanMode.depth ) )
        {
            // Get list of folders/filename
            auto folders = project.pathOfMember( entry.name ).split( dirSeparator );

            // Remove . in path.
            if( folders[ 0 ] == "." )
                folders = folders[ 1..$ ];

            // Remove .yml from from file name.
            folders[ $-1 ] = folders[ $-1 ].stripExtension;

            Node* current = &content;
            // Make a node for each file
            foreach( i, folder; folders )
            {
                // If folder doesn't already exist, add it.
                if( !current.containsKey( folder ) )
                    current.add( folder, ( i == folders.length - 1 ) ? makeArray() : makeMap() );
                // Make nested folder current.
                current = &( *current )[ folder ];
            }

            // Load the yaml file.
            auto loader = Loader( entry.name.absolutePath );
            loader.constructor = ctor;
            auto docs = loader.loadAll();

            //
            if( docs.length == 1 )
            {
                *current = docs[ 0 ];
            }
            else
            {
                foreach( doc; docs )
                {
                    if( !doc.isNull )
                        current.add( doc );
                }
            }
        }

        if( content.containsKey( "Content" ) )
            content.removeAt( "Content" );

        // Write to content file.
        Dumper( project.pathOfMember( "Content.yml" ) ).dump( content );
    }
}

class PublishCommand : Command
{
    string zipName;

    this()
    {
        name = "publish";
        argPattern = [ "[name]", "<[zip name]>" ];
    }

    override void prepare( string[] args )
    {

    }

    override void execute( Project project )
    {
        import std.zip;
        import proc = std.process;
        //TODO: Make sure Yaml is in good shape.
        //compressYaml( gameDir );

        // Current working dir.
        auto curPath = getcwd();
        chdir( project.directory );

        // Build the game.
        io.writeln( "Building game..." );
        proc.execute( [ "dub", "build", "--build=release", "--force", "-q" ] );

        // Go back to previous path.
        chdir( curPath );

        io.writeln( "Packaging distributable..." );

        // Archive to zip to.
        auto zip = new ZipArchive();

        // Directories to zip.
        auto dirs = folders.filter!( dir => dir.publishable ).map!( pth => project.pathOfMember( pth.name ) );

        // Put each file in the zip.
        foreach( dir; dirs ) foreach( file; dir.dirEntries( SpanMode.breadth ).filter!( entry => entry.isFile ) )
        {
            auto am = new ArchiveMember();
            am.compressionMethod = CompressionMethod.deflate;
            am.name = project.pathOfMember( file );
            am.expandedData = cast( ubyte[] )read( file.absolutePath );
            zip.addMember( am );
        }

        // Write the data.
        write( zipName, cast(byte[])zip.build );
    }
}
