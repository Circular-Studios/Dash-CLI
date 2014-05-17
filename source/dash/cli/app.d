module dash.cli.app;
import dash.cli.compress, dash.cli.publish;

import std.stdio, std.string, std.getopt, std.path;

void main( string[] args )
{
    if( args.length < 2 )
    {
        return printHelp();
    }

    // Default vars for execution.
    string gameDir = getcwd();

    // Get the directory of the game.
    args.getopt(
        "g|game-dir", &gameDir );

    // Make sure gameDir is normalized.
    gameDir = gameDir.absolutePath.buildNormalizedPath();

    switch( args[ 1 ].toLower )
    {
    case "compress":
        writeln( "Compressing game content" );

        compressYaml( gameDir );
        break;

    case "publish":
        writeln( "Packaging game for publishing" );

        string zipName = "game.zip";
        args.getopt(
            "o|zip-file", &zipName );

        publishGame( gameDir, zipName );
        break;

    default:
        printHelp();
        break;
    }
}

void printHelp()
{
    writeln( "Welcome to the Dash Engine!" );
}
