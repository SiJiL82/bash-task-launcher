#!/usr/bin/env bash
commands='
build-autocomplete
example
example-arg
print-things
menu
'
complete -W "${commands}" 'tl'
