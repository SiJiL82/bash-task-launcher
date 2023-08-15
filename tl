#!/usr/bin/env bash

task_launcher_name=$(basename "$0")

cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" || exit

source ./shared-functions
source ./run

# Installs this script on the PATH.
self_install() {
	local -r destination=/usr/local/bin

	# Nothing to do if already installed.
	type -P "$task_launcher_name" &>/dev/null && return

	print_info "$task_launcher_name will now install itself into $destination..."
	sudo true || :die Privilege escalation failed.

    if sudo ln -sf "$PWD/$task_launcher_name" "$destination"; then
		print_info "Installation succeeded. From now on, simply use '$task_launcher_name' to invoke this script."
    else
		print_warning Installation failed.
    fi

	exit
}


# Invokes the CLI menu.
invoke_menu() {
	source ./menu
	source ./task-functions

	menu "$(tasks:menuitems MAIN_MENU)"
}

# Invokes the named task in a subshell.
invoke_task() (
	"$@"
)

launcher() {
	local -r task=${1:-shell}

	self_install

	if [[ $task =~ ^(m|menu)$ ]]; then
		invoke_menu
	elif [[ $task =~ ^(-?h|(--)?help)$ ]]; then
		runner:help
	elif runner:has_task "$task"; then
		invoke_task "$task" "${@:2}"
	else
		print_info "No arguments supplied. Try '$task_launcher_name --help' to list available tasks"
	fi
}

launcher "$@"
