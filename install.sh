#!/usr/bin/env bash

ln -s `pwd`/.emacs $HOME/.emacs
mkdir $HOME/.emacs.d
ln -s `pwd`/desert-theme $HOME/.emacs.d/desert-theme
