#!/bin/sh

touch_minima() {
  touch ~/.config/hypr/config.conf

  cat ./defaults/hypr.conf > ~/.config/hypr/config.conf
}


