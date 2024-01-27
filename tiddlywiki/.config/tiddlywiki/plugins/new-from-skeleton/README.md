# Tiddlywiki Plugin: New Tiddlers from a Skeleton #

Adds a button to the View Toolbar which creates a draft tiddler based on a
skeleton tiddler. The skeleton tiddler can be edited by the user.

This version of the plugin uses plugin naming conventions for tiddler titles.

## Installation ##

### Single file wiki ##

Install plugin file
[$\_\_plugins\_.dtn\_new-from-skeleton.json](https://github.com/dnebauer/tw-new-from-skeleton/blob/master/%24__plugins_.dtn_new-from-skeleton.json)
to a single file wiki by:

* Dragging and dropping it into your wiki, or
* Saving the plugin tiddler file and importing it into your wiki.

### Node.js server wiki ###

Copy the contents of the `source` subdirectory to a suitable subdirectory under
the server plugins directory, and update individual wiki `tiddlywiki.info`
files accordingly.

Note: the server plugins directory may be something like
`/usr/local/lib/node_modules/tiddlywiki/plugins/`.

## License ##

This plugin is placed in the public domain.

