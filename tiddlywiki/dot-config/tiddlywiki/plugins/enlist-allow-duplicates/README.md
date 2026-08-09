# Tiddlywiki Plugin: Enable Allow Duplicates #

This plugin provides filter operator `enlistallowduplicates`, a drop in
replacement for the `enlist` operator that retains duplicate list items.

## Installation ##

### Single file wiki ##

Install plugin file
[$\_\_plugins\_.dtn\_enlist-allow-duplicates.json](https://github.com/dnebauer/tw-enlist-allow-duplicates/blob/master/%24__plugins_.dtn_enlist-allow-duplicates.json)
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

This plugin is distributed under the same license as Tiddlywiki, the [3-Clause
BSD](https://opensource.org/licenses/BSD-3-Clause) License (also known as
BSD-3-Clause, the New BSD License, and the Modified BSD License).
