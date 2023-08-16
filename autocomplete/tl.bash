#!/usr/bin/env bash
commands='
build-autocomplete
example
print-things
menu
'
complete -W "${commands}" 'tl'
