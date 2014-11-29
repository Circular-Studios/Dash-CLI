module dash.cli.commands;
import dash.cli.project, dash.cli.utility;

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
        import std.getopt: getopt, config;

        args.getopt( config.passThrough,
            "k|gitkeep", &leaveGitkeep );
    }

    override void execute( Project project )
    {
        import std.file, std.path, std.zip, std.stream, std.algorithm;
        import std.stdio: writeln;

        // Check that the empty-game.zip file exists
        string emptyGameLocation = thisExePath.dirName.buildNormalizedPath( "empty-game.zip" );
        if ( !exists(emptyGameLocation)) {
            writeln("Can't access ", emptyGameLocation);
            return;
        }

        // If the project folder doesn't exist, create it.
        if( !project.directory.exists() )
            project.directory.mkdirRecurse();

        // Extract the empty-game.zip template.
        auto zr = new ZipArchive( emptyGameLocation.read() );
        foreach( ArchiveMember de; zr.directory )
        {
            // Ignore folders.
            if( de.name[ $-1 ].among( '/', '\\' ) )
                continue;

            // Make sure folder exists.
            auto absPath = project.pathToMember( de.name );
            if( !absPath.dirName.exists )
                absPath.dirName.mkdirRecurse();

            // If we're not placing .gitkeeps, and this file is one, ignore it.
            if( de.name.baseName == ".gitkeep" && !leaveGitkeep )
                continue;

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
        import yaml: Node, Constructor, Loader, Dumper;
        import std.stream: File, FileMode;
        import std.string: strip, split, replace;
        import std.file: dirEntries, dirSeparator, SpanMode;
        import std.path: relativePath, absolutePath, stripExtension;

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
        auto f = new File( project.pathToMember( "Content.yml" ), FileMode.OutNew );
        Dumper( f ).dump( content );
        f.flush();
        f.close();
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
        import std.getopt: getopt, config;

        args.getopt( config.passThrough,
            "o|zipfile", &zipName );

        compress.prepare( args );
    }

    override void execute( Project project )
    {
        import proc = std.process;
        import std.zip;
        import std.path: getcwd, relativePath, absolutePath;
        import std.file: chdir, read, write, dirEntries, SpanMode;
        import std.stdio: writeln;
        import std.algorithm: filter, map;

        // Make sure Yaml is in good shape.
        compress.execute( project );

        // Current working dir.
        auto curPath = getcwd();
        chdir( project.directory );

        // Build the game.
        writeln( "Building game..." );
        auto result = proc.execute( [ "dub", "build", "--build=release", "--force", "--quiet" ] );

        if( result.status != 0 )
        {
            writeln( "Error(s) compiling project:\n", result.output );
            return;
        }

        // Go back to previous path.
        chdir( curPath );

        writeln( "Packaging distributable..." );

        // Archive to zip to.
        auto zip = new ZipArchive();

        // Directories to zip.
        auto dirs = folders.filter!( dir => dir.publishable ).map!( pth => project.pathToMember( pth.name ) );

        // Put each file in the zip.
        foreach( dir; dirs ) foreach( file; dir.dirEntries( SpanMode.breadth ).filter!( entry => entry.isFile ) )
        {
            auto am = new ArchiveMember();
            am.compressionMethod = CompressionMethod.deflate;
            am.name = project.pathToMember( file ).relativePath( project.directory );
            am.expandedData = cast( ubyte[] )read( file.absolutePath );
            zip.addMember( am );
        }

        // Write the data.
        write( zipName, cast(byte[])zip.build );
    }
}
