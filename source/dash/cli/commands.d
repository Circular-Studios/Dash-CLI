module dash.cli.commands;
import dash.cli.project;

abstract class Command
{
    string name;
    string[] argPattern;

    abstract void execute( Project );
}

class CreateCommand : Command
{
    this()
    {
        name = "create";
        argPattern = [ "[name]" ];
    }

    override void execute( Project project )
    {
        import std.file;

    }
}
