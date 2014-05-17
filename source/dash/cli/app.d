module dash.cli.app;
import dash.cli.compress, dash.cli.publish;

import std.stdio, std.string, std.getopt, std.path;

void main( string[] args )
{
    if( args.length < 2 )
    {
        return printHelp();
    }

    // The project to operate on.
    auto project = new Project;

    // Default vars for execution.
    string gameDir = getcwd();
    string zipName = "game.zip";

    // Get the directory of the game.
    args.getopt(
        "g|game-dir", &gameDir,
        "o|zip-file", &zipName );

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
