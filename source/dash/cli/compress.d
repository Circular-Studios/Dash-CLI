module dash.cli.compress;
import dash.cli.utility;

import yaml;
import std.stdio, std.path, std.file, std.string, std.array, std.algorithm;

void compressYaml( string gameDir )
{
    Node content = makeMap();

    enum passThrough( string tag ) = q{
        ctor.addConstructorScalar( "!$tag", ( ref Node node ) { return node.get!string; } );
    }.strip().replace( "$tag", tag );
    auto ctor = new Constructor;
    mixin( passThrough!"Verbosity" );
    mixin( passThrough!"Vector2" );
    mixin( passThrough!"Vector3" );
    mixin( passThrough!"Keyboard" );

    foreach( entry; gameDir.dirEntries( "*.y{a,}ml", SpanMode.depth ) )
    {
        // Get list of folders/filename
        auto folders = entry.name.relToGame( gameDir ).split( dirSeparator );

        // Remove . in path.
        if( folders[ 0 ] == "." )
            folders = folders[ 1..$ ];

        // Remove .yml from from file name.
        folders[ $-1 ] = folders[ $-1 ].stripExtension;

        Node* current = &content;
        // Make a node for each file
        foreach( i, folder; folders )
        {
            // If folder doesn't already exist, add it.
            if( !current.containsKey( folder ) )
                current.add( folder, ( i == folders.length - 1 ) ? makeArray() : makeMap() );
            // Make nested folder current.
            current = &( *current )[ folder ];
        }

        // Load the yaml file.
        auto loader = Loader( entry.name.absolutePath );
        loader.constructor = ctor;
        auto docs = loader.loadAll();

        //
        if( docs.length == 1 )
        {
            *current = docs[ 0 ];
        }
        else
        {
            foreach( doc; docs )
            {
                if( !doc.isNull )
                    current.add( doc );
            }
        }
    }

    if( content.containsKey( "Content" ) )
        content.removeAt( "Content" );

    // Write to content file.
    Dumper( gameDir.buildNormalizedPath( "Content.yml" ) ).dump( content );
}

private:
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
