module dash.cli.publish;
import dash.cli.utility;
import dash.cli.compress;

import std.file, std.path, std.zip, std.algorithm, std.process;
import io = std.stdio;

void publishGame( string gameDir, string zipName )
{
    // Make sure Yaml is in good shape.
    compressYaml( gameDir );

    // Current working dir.
    auto curPath = getcwd();
    chdir( gameDir );

    // Build the game.
    io.writeln( "Building game..." );
    execute( [ "dub", "build", "--build=release", "--force", "-q" ] );

    // Go back to previous path.
    chdir( curPath );

    io.writeln( "Packaging distributable..." );

    // Archive to zip to.
    auto zip = new ZipArchive();

    // Directories to zip.
    auto dirs = folders.filter!( dir => dir.publishable ).map!( pth => gameDir.buildNormalizedPath( pth.name ).absolutePath );

    // Put each file in the zip.
    foreach( dir; dirs ) foreach( file; dir.dirEntries( SpanMode.breadth ).filter!( entry => entry.isFile ) )
    {
        auto am = new ArchiveMember();
        am.compressionMethod = CompressionMethod.deflate;
        am.name = file.relToGame( gameDir );
        am.expandedData = cast( ubyte[] )read( file.absolutePath );
        zip.addMember( am );
    }

    // Write the data.
    write( zipName, cast(byte[])zip.build );
}
