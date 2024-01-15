#!/bin/bash
# shellcheck disable=

# set -o errexit
set -o pipefail
set -o noclobber

# -----------------------------------------------------------------------------
# For help text, you may use the form:
# function func_name {
#   : "Some text 1"
#   : "Some text 2"
# }
#
######## OR##################
# function func_name {
#   : "___help___ ___some-func-help"
# }
# The pattern is ___help___ ___name-help - the help function name must start
# with `___` and end with `-help`
#
# For aliases:
# function func_name {
#   : "___alias___ some-other-func"
# }
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# See also for inspiration:
# https://github.com/nickjj/docker-flask-example/blob/main/run
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Extend the search path so you can easily use executables that are not on the
# normal search path
# -----------------------------------------------------------------------------
PATH=./node_modules/.bin:$PATH

# -----------------------------------------------------------------------------
# Helper functions start with _ and aren't listed in this script's help menu.
# -----------------------------------------------------------------------------

SCRIPT_FULLNAME="$(realpath "$0")"
SCRIPT_DIR_PATH="$(dirname "$SCRIPT_FULLNAME")"

function _wait-until {
  : "Run 'command_to_run' and try until 'timeout' is reached. Usage:"
  : "  ./run.sh _wait-until [OPTIONS] command_to_run"
  : "  ./run.sh _wait-until command_to_run [OPTIONS]"
  : ""
  : "Options:"
  : "  --sleep/-s.   How long (in seconds) to wait before command is tried again"
  : "                when it fails. Defaults to 1 second."
  : "  --no-exit/-n. If true, we do not exit when timeout is reached but return."
  : "                This is great for situations where we want do not want the"
  : "                script to exit if '_wait-until' does not run successfully."
  : "  --timeout/-t. How many retries before exiting/returning. Defaults to 30"
  : ""
  : "Examples:"
  : "  ./run.sh _wait-until "echo 'something'""
  : "  ./run.sh _wait-until "echo something" --sleep 1 --timeout 2 --no-exit"
  : "  ./run.sh _wait-until command_to_run -s 1 -t 2 -n"

  local _command=
  local _timeout=30
  local _sleep=1
  local _no_exit=

  # --------------------------------------------------------------------------
  # PARSE ARGUMENTS
  # --------------------------------------------------------------------------
  local parsed

  if ! parsed="$(
    getopt \
      --longoptions=timeout:,sleep:,no-exit \
      --options=t:,s:,n \
      --name "$0" \
      -- "$@"
  )"; then
    exit 1
  fi

  # Provides proper quoting
  eval set -- "$parsed"

  while true; do
    case "$1" in
    --timeout | -t)
      _timeout="$2"
      shift 2
      ;;

    --sleep | -s)
      _sleep="$2"
      shift 2
      ;;

    --no-exit | -n)
      _no_exit=1
      shift
      ;;

    --)
      shift
      break
      ;;

    *)
      Echo "Unknown option ${1}."
      exit 1
      ;;
    esac
  done

  # handle non-option arguments
  if [[ $# -ne 1 ]]; then
    echo "$0: Non optional argument \"command\" is required."
    exit 1
  fi

  _command=$1
  # --------------------------------------------------------------------------
  # END PARSE ARGUMENTS
  # --------------------------------------------------------------------------

  _echo "Running: ${_command}"

  i=0
  until eval "${_command}"; do
    ((i++))

    if [ "${i}" -gt "${_timeout}" ]; then
      echo "Command '${_command}' failed due to ${_timeout}s timeout!"

      if [[ -z "${_no_exit}" ]]; then
        echo "Aborting!"
        exit 1
      else
        return
      fi
    fi

    sleep "${_sleep}"
  done

  _echo "Done successfully running: ${_command}"
}

function _timestamp {
  date +'%s'
}

function _raise-on-no-env {
  if [[ ! -e "${ENV_FILENAME_RAW}" ]] ||
    [[ "${ENV_FILENAME_RAW}" =~ .env.example ]]; then
    echo -e "Environment file does not exist or it's the wrong one."
    exit 1
  fi

  local _required_envs=(
    ENV_FILENAME
    PORT
    CONTAINER_IMAGE_NAME
    CONTAINER_NAME
  )

  for _env_name in "${_required_envs[@]}"; do
    printf -v _env_val "%q" "${!_env_name}"

    if [ "${_env_val}" == "''" ]; then
      echo -e "'${_env_name}' environment variable is missing"
      exit 1
    fi
  done
}

function _has-internet {
  ping -q -c 1 -W 1 8.8.8.8 >/dev/null
}

function _h {
  # First and last newlines are required in order to pretty print help text
  read -r -d '' var <<'eof'
What does function do. Usage:
  ./run.sh ping-app [OPTIONS]

Options:
  --verbose/-v. Description should be capitalized and end in a period.
  --timeout/-t. Super long
                              description's subsequent lines should start at same column as
                              first line.

Examples:
  ./run.sh ping-app
eof

  local output
  IFS=''
  while read -r line; do
    next=": \"${line}\" "
    output="${output}\n${next}"
  done <<<"$(printf "%s" "$var")"

  echo -e "${output}\n"

  if command -v xclip &>/dev/null; then
    echo -e "${output}" | xclip -selection c
  fi
}

full_line_len=$(tput cols)

function _echo {
  local text="${*}"
  local equal='*'

  local len="${#text}"
  len=$((full_line_len - len))
  local half=$((len / 2 - 1))

  local line=''

  for _ in $(seq $half); do
    line="${line}${equal}"
  done

  echo -e "\n${text}  ${line}${line}\n"
}

# -----------------------------------------------------------------------------
# END HELPER FUNCTIONS
# -----------------------------------------------------------------------------

function d {
  : "Start development server"

  elixir \
    -S mix phx.server
}

function dbuild {
  : "Build the docker image"

  _raise-on-no-env

  docker build \
    -t "$CONTAINER_IMAGE_NAME" \
    "$SCRIPT_DIR_PATH"
}

function dpush {
  : "Push the docker image to remote repository"

  docker push \
    "$CONTAINER_IMAGE_NAME"
}

function drun {
  : "Run docker image"

  _raise-on-no-env

  docker run -i -t --rm \
    --name "$CONTAINER_NAME" \
    --env-file="${ENV_FILENAME}" \
    -p "$DOCKER_PUBLISHED_SERVER_LISTEN_PORT:$PORT" \
    "$CONTAINER_IMAGE_NAME"
}

function help {
  : "List available tasks."

  if [[ -z "${1}" ]]; then
    mapfile -t names < <(compgen -A function | grep -v '^_')
  else
    mapfile -t names < <(compgen -A function | grep '^_')
  fi

  local _this_file_content
  _this_file_content="$(cat "${0}")"

  local len=0
  declare -A name_to_len_map=()

  for name in "${names[@]}"; do
    _len="${#name}"
    name_to_len_map["$name"]="${_len}"
    if [[ "${_len}" -gt "${len}" ]]; then len=${_len}; fi
  done

  declare -A _all_output=()
  declare -A _aliases=()
  declare -A _name_spaces_map=()

  len=$((len + 10))

  for name in "${names[@]}"; do
    if ! grep -qP "function\s+${name}\s+{" <<<"${_this_file_content}"; then
      continue
    fi

    local spaces=""
    _len="${name_to_len_map[$name]}"
    _len=$((len - _len))

    for _ in $(seq "${_len}"); do
      spaces="${spaces}-"
      ((++t))
    done

    local _function_def_text
    _function_def_text="$(type "${name}")"

    local _alias_name

    # Matching pattern example:
    # `: "___alias___ install-elixir"`
    _alias_name="$(awk \
      'match($0, /^ +: *"___alias___ +([a-zA-Z_-][a-zA-Z0-9_-]*)/, a) {print a[1]}' \
      <<<"${_function_def_text}")"

    if [[ -n "${_alias_name}" ]]; then
      _aliases["${_alias_name}"]="${_aliases["${_alias_name}"]} ${name}"
      continue
    fi

    local _help_func=''

    # Matching pattern example:
    # `: "___help___ ___elixir-help"`
    _help_func="$(awk \
      'match($0, /^ +: *"___help___ +(___[a-zA-Z][a-zA-Z0-9_-]*-help)/, a) {print a[1]}' \
      <<<"${_function_def_text}")"

    # Get the whole function definition text and extract only the documentation
    # part.
    if [[ -n "${_help_func}" ]]; then
      mapfile -t _doc_lines < <(
        eval "${_help_func}" 2>/dev/null
      )
    else
      mapfile -t _doc_lines < <(
        sed -nEe "s/^[[:space:]]*: ?\"(.*)\";/\1/p" <<<"${_function_def_text}"
      )
    fi

    local _output=""

    if [[ -n "${_doc_lines[*]}" ]]; then
      for _doc in "${_doc_lines[@]}"; do
        _output+="${name} ${spaces} ${_doc}\n"
      done
    else
      _output="${name} ${spaces} *************\n"
    fi

    _all_output["${name}"]="${_output}"
    _name_spaces_map["${name}"]="${name} ${spaces}"
  done

  for name in "${!_all_output[@]}"; do
    _output="${_all_output["${name}"]}"
    echo -e "${_output}"

    local _alias_names="${_aliases["${name}"]}"

    if [[ -n "${_alias_names}" ]]; then
      echo -e "${_name_spaces_map["${name}"]} ALIASES: ${_alias_names}\n\n"
    fi
  done
}

TIMEFORMAT=$'\n\nTask completed in %3lR\n'
time "${@:-help}"
