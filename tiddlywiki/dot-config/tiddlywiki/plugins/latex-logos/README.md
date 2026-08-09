# Tiddlywiki Plugin: Latex Logos #

This plugin provides macros which display latex-related logos using standard
html and css. The horizontal and vertical displacement of letters within the
logos is configurable.

## Installation ##

### Single file wiki ##

Install plugin file
[$\_\_plugins\_.dtn\_latex-logos.json](https://github.com/dnebauer/tw-latex-logos/blob/master/%24__plugins_.dtn_latex-logos.json)
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

This plugin is based on a blog posting by Theresa O’Connor from 22 August 2007:
[TEX and LATEX logo POSHlets](http://tess.oconnor.cx/2007/08/tex-poshlet). As
such, the plugin is distributed under the same license ([CC BY-SA
3.0](https://creativecommons.org/licenses/by-sa/3.0/legalcode)) as the blog
post.
