#!/usr/bin/env bash

task_launcher_name=$(basename "$0")

cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" || exit

source ./shared-functions

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

	menu "$(tasks:menuitems "$1")"
}

# Check task exists with provided name
is_task() {
	source ./task-functions

	[[ $1 ]] && grep -Fxq -- "$1" <<<"$(tasks:filter NO-RUNNER)"
}

is_menu() {
	source ./task-functions

	[[ $1 ]] && grep -Fxq -- "$1" <<<"$(tasks:menus)"
}

# Invokes the named task in a subshell.
invoke_task() (
	"$@"
)

help() {
	local -r tasks=$(tasks:filter "NO-RUNNER|NO-HELP")
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
		>&2 echo "calling main menu"
		invoke_menu MAIN_MENU
	elif [[ $task =~ ^(-?h|(--)?help)$ ]]; then
		help
	elif is_task "$task"; then
		>&2 echo "calling task"
		debug_path=$(temporary_setting TL_DEBUG_PATH)

		if [[ -z $debug_path ]]; then
			invoke_task "$task" "${@:2}"
		else
			{
				print_info "***************************************"
				print_info "Task: $*"
				print_info "***************************************"
			} &>> "$debug_path"

			invoke_task "$task" "${@:2}" | tee -a "$debug_path"
		fi
	elif is_menu "$task"; then
		>&2 echo "calling menu $task"
		invoke_menu "$task"
	else
		print_info "No / invalid arguments supplied. Try '$task_launcher_name --help' to list available tasks"
	fi
}

launcher "$@"
