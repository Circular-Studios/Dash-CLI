module dash.cli.project;

import std.path;

final class Project
{
    string name;
    string directory;

    void prepare( ref string[] args )
    {
        directory = getcwd();

        // Get the name.
        if( args.length > 1 && args[ 1 ][ 0 ] != '-' )
        {
            name = args[ 1 ];
            directory = name;
            args = args[ 0 ] ~ args[ 2..$ ];
        }
        else
        {
            name = getcwd().dirName;
            directory = getcwd();
        }

        // Make sure directory is correct
        directory = directory.absolutePath.buildNormalizedPath();
    }

    string pathToMember( string foler )
    {
        return directory.buildNormalizedPath( foler ).absolutePath.buildNormalizedPath();
    }
}
