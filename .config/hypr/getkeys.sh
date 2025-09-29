#!/bin/sh
hyprctl keyword input:kb_layout "$(localectl status | sed -n 's/^\s*X11 Layout:\s*//p')"
