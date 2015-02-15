#!/bin/bash


gcc -o pcp pcp.c
gcc -o psh psh.c

cp pcp /usr/sbin/.
cp psh /usr/sbin/.

cp pcp.1 /usr/share/man/man1/.
cp psh.1 /usr/share/man/man1/.

hash -r

