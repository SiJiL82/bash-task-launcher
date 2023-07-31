#!/usr/bin/env bash
commands='
build-autocomplete
menu
'
complete -W "${commands}" 'tl'
