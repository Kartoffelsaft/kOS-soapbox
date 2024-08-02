#!/bin/sh

rlwrap -tvt100 -a -i -f keywords.txt telnet "$1" 5410
