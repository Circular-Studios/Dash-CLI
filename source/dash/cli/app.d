module dash.cli.app;
import dash.cli.commands, dash.cli.project;

import std.algorithm, std.stdio;

void main( string[] args )
{
    // The project to operate on.
    Project project = new Project;

    // all avaliable commands.
    Command[] commands = [
        cast(Command)new CreateCommand,
        cast(Command)new CompressCommand,
        cast(Command)new PublishCommand,
    ];

    // If invalid number of args, return.
    if( args.length == 1 )
    {
        printHelp();
        return;
    }

    // Get the command.
    auto cmdIdx = commands.countUntil!( cmd => cmd.name == args[ 1 ] );
    if( cmdIdx == -1 )
    {
        fail( "Unkown command \"", args[ 1 ], "\"" );
        return;
    }

    // The command to execute.
    Command cmd = commands[ cmdIdx ];

    args = args[ 0 ] ~ args[ 2..$ ];

    // Give command the first crack at args.
    // This way commands that need a second word (e.g. `add script`)
    // can check for that before the project path get's picked.
    cmd.prepare( args );

    // Then the project.
    project.prepare( args );

    // Make sure there are no leftover args.
    if( args.length > 1 )
    {
        fail( "Unknown args: ", args[ 1..$ ] );
    }

    // Then execute.
    cmd.execute( project );
}

void fail( Args... )( Args messages )
{
    foreach( msg; messages )
        write( msg );

    writeln();

    printHelp();
}

void printHelp()
{
    writeln( "Welcome to the Dash Engine!" );
}
