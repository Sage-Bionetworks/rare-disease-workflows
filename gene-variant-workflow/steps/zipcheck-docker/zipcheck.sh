#!/bin/sh

if echo $1 | grep -q .gz; then gzip -dk $1; fi