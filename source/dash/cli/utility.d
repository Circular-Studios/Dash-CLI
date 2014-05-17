module dash.cli.utility;

import yaml;
import std.path;

struct Folder
{
    string name;
    bool publishable;
}

enum binaries = Folder( "Binaries", true );
enum config = Folder( "Config", false );
enum scripts = Folder( "Scripts", false );
enum materials = Folder( "Materials", false );
enum meshes = Folder( "Meshes", true );
enum objects = Folder( "Objects", false );
enum prefabs = Folder( "Prefabs", false );
enum textures = Folder( "Textures", true );
enum ui = Folder( "UI", true );

Folder[] folders = [
    binaries, config, materials,
    meshes, objects, prefabs,
    scripts, textures, ui
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
