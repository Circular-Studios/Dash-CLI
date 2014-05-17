module dash.cli.create;
import dash.cli.utility;

import std.file, std.path;

string dubJson =
q{{
    "name": "dash-game",
    "description": "A game built with Dash.",
    "copyright": "2014",
    "license": "MIT",
    "authors": [
        "Your Name Here"
    ],
    "dependencies": {
        "dash": "~>0.9.0"
    },
    "sourcePaths": [
        "Scripts/",
        "Config/",
        "Materials/",
        "Objects/",
        "Prefabs/",
        "UI/",
    ],
    "importPaths": [ "Scripts/" ],
    "targetType": "executable",
    "targetPath": "Binaries",
    "workingDirectory": "Binaries",
    "lflags-linux" : [ "./libawesomium-1.6.5.so" ],
    "libs-windows": [
        "Awesomium",
        "gdi32", "ole32", "kernel32",
        "user32", "comctl32", "comdlg32"
    ],

    "stringImportPaths": [ "./" ],

    "buildTypes": {
        "release": {
            "versions": [ "EmbedContent" ],
            "buildOptions": [ "releaseMode", "optimize", "inline" ],
            "lflags-windows": [ "/EXETYPE:NT", "/SUBSYSTEM:WINDOWS" ]
        }
    }
}};

void createProject( string gameDir )
{
    // If the project folder doesn't exist, create it.
    if( !gameDir.exists() )
        gameDir.mkdirRecurse();

    // Unzip empty game to new folder.


    // Create the generic dub.json.
    write( "dub.json".inGame( gameDir ), dubJson );
}
