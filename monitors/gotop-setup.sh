#!/bin/bash

git clone --depth 1 https://github.com/cjbassi/gotop /tmp/gotop

/tmp/gotop/scripts/download.sh

sudo mv gotop /usr/bin/

rm -rf /tmp/gotop
