# Tiddlywiki plugins

See the individual plugin folders for an explanation of each.

What follows is a description of my personal workflow regarding these plugins.

## Create plugin files

Create plugin files in a nodejs version of TW:

- Include documentary files such as "readme" (required), "credits" (optional)
  and "license" (highly recommended)
- Put all plugin files under `$:/plugins/.dtn/PLUGIN_NAME/`.

## Copy the plugin files to the server plugin directory tree

The plugin files are in the `tiddlers` subdirectory of the nodejs wiki and have
filenames beginning with `$__plugins_.dtn_my-plugin_`.

Move them all to the server plugin directory tree. On my current system this is
`/usr/local/share/tiddlywiki/plugins`.

- TiddlyWiki is made aware of this plugins directory by the
  `$TIDDLYWIKI_PLUGIN_PATH` defined in `~/.zshrc`.

My plugins are all placed under the `dtn` subdirectory of the plugins
directory.

- Each of my plugins has its own subdirectory under `dtn`
- Subdirectories should have ownership permissions 755, e.g.,
  `sudo mkdir -p -m 755 dtn/my-plugin`
- By convention individual plugin directory names are lower case with
  dash-separated words, e.g., `my-plugin`
- Ensure all plugin files have permissions 644 and inherit the owners
  "root:staff" -- the following command may be useful:
  `chown -R root:staff my-plugins`.

## Rename and reorganise plugin files

The name and location of files in the plugin directory are irrelevant. Files
can be placed in an arbitrary subdirectory tree. Names can be simplified, e.g.,
from `$__plugins_.dtn_my-plugin_config` to `config`. It helps to prevent
confusion if file names remain unique within a plugin, but it is not necessary.
(That is, files in different subdirectories of the same plugin could have the
same name.)

The idea is to make it as simple as possible to understand the macro files and
their relationships with each other.

It is common to put all documentation files, such as "readme", "credits" and
"license", into a `doc` subdirectory.

## Create a `plugin.info` file

Complete a `plugin.info` file in the plugin root directory. Use the following
as a template:

```json
{
  "title": "$:/plugins/.dtn/utility-macros",
  "description": "Utility macros used by David Nebauer",
  "author": "David Nebauer",
  "version": "0.0.1",
  "core-version": ">=5.1.21",
  "source": "https://github.com/dnebauer/tw-utility-macros",
  "list": "readme credits license",
  "dependents": "",
  "plugin-type": "plugin"
}
```

Note that it uses json syntax.

## Configure the tiddlywiki to use the server version

Edit the `tiddlywiki.info` file in the wiki root directory. To the "plugins"
array add an entry like "dtn/my-plugin". (This file uses the relative directory
path from the server plugin directory root.)

Stop and restart the tiddlywiki server for this change to take effect.

## Create single plugin file intended for github repository

This file is intended for use in installing into single-file tiddywikis.

It is created by running the `tw-plugin-join` utility with the plugin's root
directory as an argument. The utility can create either a `tid` (default) or
`json` formatted plugin file in the current directory. Although the `tid`
format is the utility's default, the modern practice is to use `json` formatted
files as they are more robust.

Here is an example:

```bash
tw-plugin-join -f json /usr/local/share/tiddlywiki/plugins/dtn/my-plugin
```

This creates a file in the current directory called
`$__plugins_.dtn_my-plugin.json`.

Note that `tw-plugin-join` must be run from an empty directory.

## Create github repository for plugin

The user's practice is to package each tiddlywiki plugin into its own github
repository. Follow these steps:

1. Create new plugin directory under `~/.config/tiddlywiki/plugins`.
2. Copy a `README.md` directory from a previously created plugin repository and
   edit it to apply to the current plugin.
3. Move the single plugin file into the plugin directory.
4. Create a `source` subdirectory.
5. Bind the plugin files' directory tree to the `source` directory with a
   command like:
   `bindsfs /usr/local/share/tiddlywiki/plugins/dtn/my-plugin source`.
6. Create a new git repository using `git init`, `git add *`, and
   `git commit -m 'Initial import'`.
7. Navigate to github in browser, sign in if necessary, got to Repositories
   page, click on New, name the new repository like "tw-plugin_name" with a
   description like "Tiddlywiki plugin: plugin name".
8. Follow github instructions for pushing an existing repository from the
   command line, currently `git remote add origin GITHUB_PATH`,
   `git branch -M master`, and `git push -u origin master`.
9. Unbind the plugin files' directory tree with a command like:
   `fusermount -u source`.

## Future changes to plugin files

Existing plugin files can be edited within a nodejs wiki using the plugin. This
creates an altered version of the file in the wiki's `tiddlers` subdirectory.
This file has the original style of filename based on the tiddler title, e.g.,
`$__plugins_.dtn_my-plugin_TIDDLER_TITLE`.

New plugin tiddlers can likewise be created. They should follow the tiddler
title convention of starting with `$:/plugins/.dtn/my-plugin/TIDDLER_TITLE`,
and will result in files with names based on those titles.

Once changes to the plugin are complete, move the new and changed files to the
plugin files in the server plugins directory tree, changing the file names and
locating them appropriately in the plugin's subdirectory tree, and overwriting
previous version of the files.

Stop and restart the tiddlywiki server.

Re-create a single plugin json file:

```bash
mkdir -p ~/tmp/tw-plugin  # must be an empty directory
cd ~/tmp/tw-plugin
tw-plugin-join -f json /usr/local/share/tiddlywiki/plugins/dtn/my-plugin
```

Copy the resulting file to the plugin's repository directory under
`~/.config/tiddlywiki/plugins`.

Update the plugin's github repository:

1. Change to the plugin's directory under `~/.config/tiddlywiki/plugins`.
2. Copy the single plugin json file to the repository root directory,
   overwriting the previous version.
3. Bind the plugin files' directory tree to the `source` directory with a
   command like:
   `bindsfs /usr/local/share/tiddlywiki/plugins/dtn/my-plugin source`.
4. Update the repository with the changes using `git add *`, and
   `git commit -m 'EXPLAIN CHANGES'`, and `git push`.
5. Unbind the plugin files' directory tree with a command like:
   `fusermount -u source`.
