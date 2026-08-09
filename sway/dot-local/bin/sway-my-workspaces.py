#!/usr/bin/python3

# sourced from
# https://git.sr.ht/~roselandgoose/Sway_Layout_Restore/blob/main/sway_workspaces.py
# by https://github.com/roselandgoose

# adapted from https://gist.github.com/Nama/55786d0b2a8349d11f9013fa1a86e6b1
# by https://github.com/Nama

'''
Original comments by @Nama:
--------------------------

* setup displays first, e.g. with wdisplay 
* run after setting up your displays:
  `python sway_workspaces.py save <profilename>`
* repeat for every display setup
* setup kanshi and make it run:
  `python sway_workspaces.py load <profilename>`

Multiple windows of an application/class aren't handled. No idea how to do so.
Had to alter the default tree, so the outputs are not the ports.
Now it doesn't matters if more ports appeared after docking.

New comments by @roselandgoose:
------------------------------

I've modified @Nama's script above to support multiple windows of the same
program - for my many firefox windows...
I've also made the layout file argument optional.
'''

import os
import sys
import json
import i3ipc
import pickle
from time import sleep
from datetime import datetime
from glob import glob
from difflib import SequenceMatcher

def similar(a, b):
    return SequenceMatcher(None, a, b).ratio()

try:
    import sh
except ImportError:
    sh = None
if sh:
    try:
        from sh import dunstify
    except ImportError:
        dunstify = None
        notifysend = sh.Command('notify-send')

PATH = os.path.expanduser('~/.config/i3/workspace_')
workspace_mapping = None
appname = sys.argv[0]

def notify(headline, text):
    if dunstify:
        dunstify(f'--appname={appname}', headline, text)
    else:
        notifysend(headline, text)

def node_getter(nodes):
    if 'app_id' in nodes['nodes'][0].keys():
        return nodes
    return node_getter(nodes['nodes'][0])

touched = []
def have_touched(tree_app):
    return tree_app in touched

def touch_app(tree_app):
    if not have_touched(tree_app):
        touched.append(tree_app)

defaulted = []
def get_app(tree, app):
    if app.get('app_id'):
        # wayland
        app_class = app['app_id']
    elif app.get('window'):
        # xwayland
        app_class = app.get('window_properties').get('class')
    else:
        return None
    found_apps = tree.find_classed(app_class)
    found_apps = [ tree_app for tree_app in found_apps if not have_touched(tree_app) ]
    if len(found_apps) == 0:
        return None
    elif len(found_apps) == 1:
        return found_apps[0]
    name = app.get('name')
    for tree_app in found_apps:
        if tree_app.name == name:
            return tree_app
    found_apps.sort(key=lambda tree_app: similar(tree_app.name, name))
    tree_app = found_apps[-1]
    defaulted.append(tree_app)
    return tree_app

sleep(2)

couldnt_find = []
if __name__ == '__main__':
    usage = f'Usage: {sys.argv[0]} <load|save> [profilename]'
    if len(sys.argv) <= 1:
        notify('Not enough parameters!', 'Exiting')
        print(usage)
        sys.exit(1)
    command = sys.argv[1]
    if not command in ['save', 'load']:
        notify('Invalid command!', 'Exiting')
        print(usage)
        sys.exit(1)
    if len(sys.argv) > 2:
        profile = sys.argv[2]
    elif command == 'save':
        profile = datetime.now().strftime("%Y.%m.%d_%H:%M:%S")
    else:
        matches = sorted(glob(f'{PATH}*_tree.json'))
        if not matches:
            notify('No profiles to load', 'Exiting')
            sys.exit(1)
        profile = matches[-1].lstrip(PATH).rstrip('_tree.json')

    i3 = i3ipc.Connection()
    tree = i3.get_tree()
    if command == 'save':
        # save current tree
        tree_file = open(f'{PATH}{profile}_tree.json', 'w')
        json.dump(tree.ipc_data, tree_file, indent=4)
        # save workspaces
        workspaces = i3.get_workspaces()
        outputs = i3.get_outputs()
        for i, ws in enumerate(workspaces):
           for output in outputs:
               if output.name == ws.output:
                   make = output.make
                   model = output.model
                   serial = output.serial
                   output_identifier = f'{make} {model} {serial}'
                   workspaces[i].output = output_identifier
                   break
        pickle.dump(workspaces, open(PATH + profile, 'wb'))
        notify('Saved Workspace Setup', profile)
    elif command == 'load':
        try:
            workspace_mapping = pickle.load(open(PATH + profile, 'rb'))
        except FileNotFoundError:
            workspace_mapping = None
        if not workspace_mapping:
            notify('Can\'t find this mapping', profile)
            sys.exit(1)

        # Move applications to the workspaces
        tree_file = open(f'{PATH}{profile}_tree.json')
        tree_loaded = json.load(tree_file)
        for output in tree_loaded['nodes']:
            if output['name'] == '__i3_scratch':
                continue
            for ws in output['nodes']:
                ws_name = ws['name']
                ws_orientiation = ws['orientation']
                if len(ws['nodes']) == 0:  # empty workspace
                    continue
                apps = node_getter(ws)  # incase of nested workspace, can happen indefinitely
                for app in apps['nodes']:
                    tree_app = get_app(tree, app)
                    if not tree_app:
                        couldnt_find.append(app)
                        continue
                    touch_app(tree_app)
                    if ws_orientiation == 'horizontal':
                        o = 'h'
                    else:
                        o = 'v'
                    tree_app.command(f'split {o}')
                    tree_app.command(f'move container to workspace {ws_name}')

        if len(defaulted) != 0:
            print(f"chose {len(defaulted)} heuristically")
        total = len(tree.leaves())
        num_touched = len(touched)
        if num_touched != total:
            print(f"left {total - num_touched} untouched")
        if len(couldnt_find) != 0:
            print(f"couldn't find {len(couldnt_find)}")

        # Move workspaces to outputs
        for workspace in workspace_mapping:
            i3.command(f'workspace {workspace.name}')
            i3.command(f'move workspace to output "{workspace.output}"')
        for workspace in filter(lambda w: w.visible, workspace_mapping):
            i3.command(f'workspace {workspace.name}')
        notify('Loaded Workspace Setup', profile)
