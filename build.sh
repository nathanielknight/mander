#!/bin/bash

elm-make elm-src/Main.elm --output output/app.js || exit 1
lessc less-src/style.less output/style.css || exit 1
cp static-src/* output/ || exit 1
