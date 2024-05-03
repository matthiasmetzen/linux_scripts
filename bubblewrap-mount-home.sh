#!/bin/bash
mkdir -p $HOME/.sandboxes/default/home
mkdir -p $HOME/.sandboxes/default/work
mkdir -p $HOME/.sandboxes/default/merged
fuse-overlayfs -o lowerdir=$HOME,upperdir=$HOME/.sandboxes/default/home,workdir=$HOME/.sandboxes/default/work ~/.sandboxes/default/merged