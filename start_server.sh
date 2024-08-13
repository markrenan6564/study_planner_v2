#!/bin/bash
node ./node/app.js > /dev/null &
php -S localhost:8000 -t ./ > /dev/null &