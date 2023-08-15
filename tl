#!/usr/bin/env bash

TASK_LAUNCHER_NAME="tl"

cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" || exit

source ./shared-functions
source ./run

# Installs this script on the PATH.
self_install() {
	local -r destination=/usr/local/bin script_name=$(basename "${BASH_SOURCE[0]}")

	# Nothing to do if already installed.
	type -P "$script_name" &>/dev/null && return

	echo "$script_name will now install itself into $destination..."
	sudo true || :die Privilege escalation failed.

    if sudo ln -sf "$PWD/$script_name" "$destination"; then
		print_info "Installation succeeded. From now on, simply use '$script_name' to invoke this script."
    else
		print_warning Installation failed.
    fi
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
		print_info "No arguments supplied. Try '$TASK_LAUNCHER_NAME --help' to list available tasks"
	fi
}

launcher "$@"
