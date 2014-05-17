module dash.cli.project;

final class Project
{
    string name;
    string directory;

    string pathOfMember( string foler )
    {
        import std.path;
        return directory.buildNormalizedPath( foler ).absolutePath.buildNormalizedPath();
    }
}
