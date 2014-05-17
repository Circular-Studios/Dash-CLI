module dash.cli.app;
import dash.cli.compress, dash.cli.publish, dash.cli.create;

import std.stdio, std.string, std.getopt, std.path;

void main( string[] args )
{
    if( args.length < 2 )
    {
        printHelp();
        return;
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
    case "create":
        writeln( "Creating a new project" );

        createProject( gameDir );
        break;

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
