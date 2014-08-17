module dash.cli.project;

final class Project
{
    string name;
    string directory;

    void prepare( ref string[] args )
    {
        import std.path: getcwd, dirName, absolutePath, buildNormalizedPath;

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

    string pathToMember( string folder )
    {
        import std.path: absolutePath, buildNormalizedPath;
        return directory.buildNormalizedPath( folder ).absolutePath.buildNormalizedPath();
    }
}
