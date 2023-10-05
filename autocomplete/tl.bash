#!/usr/bin/env bash
commands='
build-autocomplete
example
example-arg
example-options
print-things
menu
'
complete -W "${commands}" 'tl'
