#!/bin/sh

set -e

# first arg is `-f` or `--some-option`
#if [ "${1#-}" != "$1" ]; then
#	set -- php-fpm "$@"
#fi

entrypoint_log() {
    if [ -z "${ENTRYPOINT_QUIET_LOGS:-}" ]; then
        echo "$@"
    fi
}

entrypoint_execute() {
    local type=$1
    if [ $type = "system" ]; then
        local dir="/docker-entrypoint.d/"
        entrypoint_log "$0: Running system entrypoint scripts"
    elif [ $type = "custom" ]; then
        local dir="/docker-entrypoint.custom.d/"
        entrypoint_log "$0: Running custom entrypoint scripts"
    else
        return 1
    fi
    if /usr/bin/find "${dir}" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
        entrypoint_log "$0: ${dir} is not empty, will attempt to perform configuration"

        entrypoint_log "$0: Looking for shell scripts in ${dir}"
        find "${dir}" -follow -type f -print | sort -V | while read -r f; do
            case "$f" in
                *.envsh)
                    if [ -x "$f" ]; then
                        entrypoint_log "$0: Sourcing $f";
                        . "$f"
                    else
                        # warn on shell scripts without exec bit
                        entrypoint_log "$0: Ignoring $f, not executable";
                    fi
                    ;;
                *.sh)
                    if [ -x "$f" ]; then
                        entrypoint_log "$0: Launching $f";
                        "$f"
                    else
                        # warn on shell scripts without exec bit
                        entrypoint_log "$0: Ignoring $f, not executable";
                    fi
                    ;;
                *) entrypoint_log "$0: Ignoring $f";;
            esac
        done

        entrypoint_log "$0: Configuration complete; ready for start up"
    else
        entrypoint_log "$0: No files found in ${dir}, skipping configuration"
    fi
    return 0
}

entrypoint_execute "system"
entrypoint_execute "custom"

exec "$@"