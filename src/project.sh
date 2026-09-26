#!/bin/sh
# GlAIpnir - AI Agents Sandbox - Manage a secure, isolated environment for
# running agents.
# Copyright (C) 2026  val4oss <val4oss@pm.me>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANYWARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# ================
# Global variables
# ----------------

# Return codes
SUCCESS=0
FAILURE=1

# Main variables
PRJ_ID="${PRJ_ID:-project}"
VERSION="${VERSION:-1.0.0}"

# Path variables
ROOT_D="$(cd "$(dirname "$0")/.." && pwd)"
#DATA_D="${ROOT_D}"
#SCRIPT_P="$(realpath "$0")"
CONF_P_DEFAULT="${XDG_CONFIG_HOME:-${HOME}/.config}/${PRJ_ID}/${PRJ_ID}.conf"
CONF_P="${CONF_P_DEFAULT}"
#CACHE_D_DEFAULT="${XDG_CACHE_HOME:-${HOME}/.cache}/${PRJ_ID}"
#CACHE_D="${CACHE_D_DEFAULT}"
#HOME_DATA_D_DEFAULT="${XDG_DATA_HOME:-${HOME}/.local/share}/${PRJ_ID}"
#HOME_DATA_D="${HOME_DATA_D_DEFAULT}"

# argument variables
ACTION=""
DEBUG=0

# Internal needed variables
TOOLS_NEEDED="sed grep"

# ========
# Includes
# --------

. "${ROOT_D}/src/printer.sh"

# ==================
# Internal functions
# ------------------

###
# check if needed tools are available on the system
# GLOBALS:
#   TOOLS_NEEDED
# OUTPUTS:  
#   fd 3: Error message
# RETURNS:
#   SUCCESS, FAILURE if a tool is missing
###
_check_tools_needed() {
    _ctn_rc="$SUCCESS"
    for dep in $TOOLS_NEEDED; do
        if ! command -v "$dep" > /dev/null 2>&1; then
            if [ ${missing_deps+x} ]; then
                missing_deps="$missing_deps $dep"
            else
                missing_deps="$dep"
            fi
        fi
    done
    if [ ${missing_deps+x} ]; then
        print_error "Some tools are missing on your system: $missing_deps"
        _ctn_rc="$FAILURE"
    fi
    return "$_ctn_rc"
}

###
# parse configuration file if it exists
# RETURNS:
#   SUCCESS, FAILURE if conf not valid
###
_parse_conf() {
    _pc_rc="${SUCCESS}"
    if [ -f "$CONF_P" ]; then
        _in_block=0
        _block_key=""
        while IFS= read -r _line; do
            # strip leading whitespace
            _line="${_line#"${_line%%[! ]*}"}"
            case "$_line" in
                "" | \#*) continue ;;
            esac
            if [ "$_in_block" -eq 1 ]; then
                case "$_line" in
                    *")"*) 
                        _in_block=0
                        _block_key=""
                        ;;
                    *)
                        # strip quotes
                        _item=$(printf '%s' "$_line" \
                            | sed 's/^["'"'"']//;s/["'"'"']$//')
                        # Assigning to block keys
                        case "$_block_key" in
                            #VAR) VAR="$VAR $_item" ;;
                        esac
                        ;;
                esac
            else
                _key="$(printf '%s' "$_line" | cut -d '=' -f 1)"
                _value="$(printf '%s' "$_line" | cut -d '=' -f 2-)"
                # strip quotes
                _value=$(printf '%s' "$_value" \
                    | sed 's/^["'"'"']//;s/["'"'"']$//')
                case "$_value" in
                    *"("*) 
                        _in_block=1
                        _block_key="$_key"
                        ;;
                    *)
                        # Assigning to keys
                        case "$_key" in
                            #VAR)   VAR="${_value}" ;;
                        esac
                        ;;
                esac
            fi
        done < "$CONF_P"
    fi
    return "${_pc_rc}"
}

# ================
# Action functions
# ----------------

###
# Print usage information
# GLOBALS:
#   PRJ_ID
# OUTPUTS:
#   The usage
###
usage() {
    _str="Usage: ${PRJ_ID} [-q|-v|-h] <actions> [options]
  -q, --quiet   Suppress all output except errors
  -v, --verbose Enable verbose output
  -vv           Enable verbose and debug logs for internal commands
  --version     Show version information and exit
  -h, --help    Show this help message and exit

Actions:
  action        Action to defined

Options:
  --conf       Defined conf file path for building the image. See Notes.

Notes:
  - Some notes of the projec."
    printf "%s\n" "$_str"
}

##
# Print version information
# GLOBALS:
#   PRJ_ID VERSION
# OUTPUTS:
#   version value
###
print_version() {
    printf "%s version: %s\n" "${PRJ_ID}" "$VERSION"
}

###
# Example of example function
# OUTPUTS
#   Exampel messages
#   fd 3: debug
# RETURNS
#   SUCCESS
###
# shellcheck disable=SC2329
action() {
    _a_rc="${SUCCESS}"
    printf "Hello World\n"
    [ "${DEBUG}" -eq  1 ] && printf "Debug mode\n"
    return "${_a_rc}"
}

# ===========
# Entry point
# -----------

# Get arguments
if [ $# -lt 1 ]; then
    print_error "Missing command"
    usage; exit 1
fi

if [ -f "${CONF_P}" ]; then
    if ! _parse_conf; then
        print_error "Failed to parse configuration file: $CONF_P"
        exit "${FAILURE}"
    fi
fi

while [ $# -gt 0 ]; do
    case "$1" in
        help|--help|-h)          usage;                     exit "${SUCCESS}" ;;
        quiet|--quiet|-q)        QUIET=1;                   shift 1           ;;
        version|--version)       print_version;             exit "${SUCCESS}" ;;
        action)                  ACTION="action";           shift 1           ;;            
        verbose|--verbose|-v)    VERBOSE=1;                 shift 1           ;;
        -vv)                     VERBOSE=1; DEBUG=1;        shift 1           ;;
        --conf)
            CONF_P="$2"
            if ! _parse_conf; then
                print_error "Failed to parse configuration file: $CONF_P"
                exit "${FAILURE}"
            fi
            shift 2
            ;;
        -*)
            print_error "Unknown option: $1"
            usage
            exit "${FAILURE}"
            ;;
        *)
            print_error "Unknown action: $1"
            usage
            exit "${FAILURE}"
            ;;
    esac
done

_check_tools_needed || {
    print_error "Please install the missing tools and try again. Aborting."
    exit "${FAILURE}"
}

if [ -z "${ACTION}" ]; then
    print_warning "No action specified. Nothing to do."
    usage
elif ! eval "$ACTION"; then
    print_error "[✗] Action '$ACTION' failed."
    exit "${FAILURE}"
else
    print_debug "[✓] Done."
fi

exit "${SUCCESS}"
