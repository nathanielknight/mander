#!/bin/bash

rm -r output
elm-make elm-src/Main.elm --output output/app.js
lessc less-src/style.less output/style.css
cp static-src/* output/
