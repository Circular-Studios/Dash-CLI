module dash.cli.utility;

import yaml;
import std.path;

struct Folder
{
    enum binaries = Folder( "Binaries", true );
    enum config = Folder( "Config", false );
    enum scripts = Folder( "Scripts", false );
    enum materials = Folder( "Materials", false );
    enum meshes = Folder( "Meshes", true );
    enum objects = Folder( "Objects", false );
    enum prefabs = Folder( "Prefabs", false );
    enum textures = Folder( "Textures", true );
    enum ui = Folder( "UI", true );

    string name;
    bool publishable;
}

Folder[] folders = [
    Folder.binaries, Folder.config, Folder.materials,
    Folder.meshes, Folder.objects, Folder.prefabs,
    Folder.scripts, Folder.textures, Folder.ui,
];

Node makeMap()
{
    Node content = [ "": "" ];
    content.removeAt( 0 );
    return content;
}

Node makeArray()
{
    Node content = [ "" ];
    content.removeAt( 0 );
    return content;
}
