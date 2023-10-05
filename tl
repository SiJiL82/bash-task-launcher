#!/usr/bin/env bash

task_launcher_name=$(basename "$0")

cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" || exit

source ./shared-functions
source ./task-functions
source ./colours

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

	menu "$(tasks:menuitems MAIN_MENU)"
}

# Invokes the named task in a subshell.
invoke_task() (
	"$@"
)

# Check if arg provided is a task
task_exists() {
	[[ $1 ]] && grep -Fxq -- "$1" <<<"$(get_runnable_tasks)"
}

launcher:help() {
	local -r tasks=$(get_runnable_tasks)
	local task longest_task_name
	local -r padding=2

	cat <<-.
		${BLUE}usage:$NC '$0' <task> [arg]...

		${BLUE}These tasks are available:$NC

	.

	longest_task_name=$(get_longest_task_name)

	while read -r task; do
		print_option "$task" "$((-(longest_task_name+padding)))" " $("$task":describe)"
	done < <(sort <<<"$tasks")
	echo
}

launcher() {
	local -r task=${1:-shell}

	self_install

	if [[ $task =~ ^(m|menu)$ ]]; then
		invoke_menu
	elif [[ $task =~ ^(-?h|(--)?help)$ ]]; then
		launcher:help
	elif task_exists "$task"; then
		invoke_task "$task" "${@:2}"
	else
		print_info "No arguments supplied. Try '$task_launcher_name --help' to list available tasks"
	fi
}

launcher "$@"
