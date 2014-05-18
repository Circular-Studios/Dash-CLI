module dash.cli.commands;
import dash.cli.project;
import dash.cli.utility;

import std.getopt, std.algorithm, std.string, std.array, std.file, std.path;
import io = std.stdio;

abstract class Command
{
    string name;
    string[] argPattern;

    this( string name, string[] argPattern )
    {
        this.name = name;
        this.argPattern = argPattern;
    }

    abstract void prepare( ref string[] );
    abstract void execute( Project );

    void opCall( Project project )
    {
        execute( project );
    }
}

class CreateCommand : Command
{
    bool leaveGitkeep;

    this()
    {
        super( "create", [ "[project]" ] );

        leaveGitkeep = false;
    }

    override void prepare( ref string[] args )
    {
        args.getopt(
            "k|gitkeep", &leaveGitkeep );
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
            auto absPath = project.pathToMember( de.name );
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
        super( "compress", [ "[project]" ] );
    }

    override void prepare( ref string[] args )
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
            auto folders = project.pathToMember( entry.name ).relativePath( project.directory ).split( dirSeparator );

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

            // If there's only 1 document, don't make it a sequence.
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
        Dumper( project.pathToMember( "Content.yml" ) ).dump( content );
    }
}

class PublishCommand : Command
{
    string zipName;
    CompressCommand compress;

    this()
    {
        super( "publish", [ "[project]" ] );

        zipName = "game.zip";
        compress = new CompressCommand;
    }

    override void prepare( ref string[] args )
    {
        args.getopt(
            "o|zipfile", &zipName );

        compress.prepare( args );
    }

    override void execute( Project project )
    {
        import std.zip;
        import proc = std.process;
        // Make sure Yaml is in good shape.
        compress.execute( project );

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
        auto dirs = folders.filter!( dir => dir.publishable ).map!( pth => project.pathToMember( pth.name ) );

        // Put each file in the zip.
        foreach( dir; dirs ) foreach( file; dir.dirEntries( SpanMode.breadth ).filter!( entry => entry.isFile ) )
        {
            auto am = new ArchiveMember();
            am.compressionMethod = CompressionMethod.deflate;
            am.name = project.pathToMember( file );
            am.expandedData = cast( ubyte[] )read( file.absolutePath );
            zip.addMember( am );
        }

        // Write the data.
        write( zipName, cast(byte[])zip.build );
    }
}
