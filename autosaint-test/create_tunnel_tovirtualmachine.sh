#!/bin/sh

echo 'listening on port 10521'

ssh nmsuser@172.27.66.144 -N -L10521:172.27.66.144:1521
