#!/bin/bash

# Just print some color combos out.
# -Christopher Welborn 09-25-2015
appname="test_colr"
appversion="0.0.3"
apppath="$(readlink -f "${BASH_SOURCE[0]}")"
appscript="${apppath##*/}"
appdir="${apppath%/*}"

# shellcheck source=/home/cj/scripts/bash/colr/colr.sh
source "$appdir/colr.sh"

function echo_err {
    # Echo to stderr.
    echo -e "$@" 1>&2
}

function fail {
    # Echo to stderr and exit with an error status code.
    echo_err "$@"
    exit 1
}

function get_max_cols {
    # Get maximum number of columns to show for each row,
    # based on number of items available and terminal width.
    # Arguments:
    #   $1 : Overall item count (all columns).
    #   $2 : Width of each item (col width).
    local itemcount=$1
    [[ -z "$1" ]] && fail "Expected item count for get_max_cols!"
    local colwidth=$2
    [[ -z "$2" ]] && fail "Expected column width for get_max_cols!"
    # echo_err "ITEM COUNT: $itemcount"
    # echo_err " COL WIDTH: $colwidth"
    # Get terminal width, default to 80 on tput error.
    local termcols
    termcols="$(tput cols)" || termcols=80
    [[ -z "$termcols" ]] && termcols=80
    # echo_err "TERM WIDTH: $termcols"
    # Maximum number of columns that will fit.
    local colmaxwidth=$((termcols / colwidth - 1))
    # echo_err "  MAX COLS: $colmaxwidth"
    # Maximum number of columns to use for each row, default is the max.
    local columncnt=$colmaxwidth
    # Determine most columns to use for each row, looking for 'even' fit.
    local trycolumncnt
    for trycolumncnt in $(seq "$colmaxwidth" -1 3); do
        # echo_err "Trying $itemcount & $trycolumncnt == $((itemcount % trycolumncnt))"
        if ((itemcount % trycolumncnt == 0)); then
            columncnt=$trycolumncnt
            break
        fi
    done
    printf "%s" "$columncnt"
}

function pad_text {
    # Pads the F: color, B: color labels.
    # Arguments:
    #   $1 : Label to pad.
    #   $2 : Width to pad. Default: 35
    local width=$2
    [[ -z "$width" ]] && fail "Width expected for pad_text!"
    printf "%-*s" "$width" "$1"
}

function pad_num {
    # Pad a number with 0's.
    # Arguments:
    #   $1 : Number to pad.
    #   $2 : Width to pad. Default: 3
    local width="${2:-3}"
    printf "%-*s" "$width" "$1"
}

function print_named {
    # Print all named colors.
    # Max width of each label/column.
    local colwidth=30
    # Max number of columns per row.
    local columncnt
    # Get a count of named fore color keys.
    local fore_total=0
    local numpat='^[0-9]'
    local forename
    # shellcheck disable=SC2154
    # ..fore is sourced.
    for forename in "${!fore[@]}"; do
        [[ "$forename" =~ $numpat ]] && continue
        let fore_total+=1
    done
    columncnt="$(get_max_cols "$fore_total" "$colwidth")"
    local cnt=1
    local forecnt=0
    local backname
    local label_text
    # shellcheck disable=SC2154
    # ..fore and back are sourced.
    for backname in "${!back[@]}"; do
        # Skip number keys, use names only.
        [[ "$backname" =~ $numpat ]] && continue
        for forename in "${!fore[@]}"; do
            [[ "$forename" =~ $numpat ]] && continue
            let forecnt+=1
            label_text="B:$(pad_text "$backname" 11), F:$(pad_text "$forename" 11)"
            printf "%-40s" "$(colr "$(pad_text "$label_text" "$colwidth")" "$forename" "$backname")"
            if (( cnt == columncnt )); then
                printf "\n"
                let cnt=1
            else
                let cnt+=1
                ((forecnt < fore_total)) && printf "|"
            fi
        done
        let forecnt=0
        let cnt=1
        printf "\n"
    done
}

function print_ranges {
    # Print a range of numbered colors.
    # Arguments:
    #   $1 : Fore start.
    #   $2 : Fore end.
    #   $3 : Back start.
    #   $4 : Back end.
    local fore_start="${1:-0}"
    local fore_end="${2:-255}"
    local back_start="${3:-0}"
    local back_end="${4:-255}"
    # Clamp values at 0-255.
    ((fore_start < 0)) && fore_start=0
    ((fore_end > 255)) && fore_end=255
    ((back_start < 0)) && back_start=0
    ((back_end > 255)) && back_end=255
    # Maximum column width with label and numbers.
    local colwidth=13
    # Number of fore colors for each back color.
    local fore_total=$((fore_end - fore_start + 1))
    local columncnt
    columncnt="$(get_max_cols "$fore_total" "$colwidth")"

    local cnt=1
    local forecnt=0
    local backnum
    local forenum
    local label_text
    for backnum in $(seq "$back_start" "$back_end"); do
        for forenum in $(seq "$fore_start" "$fore_end"); do
            let forecnt+=1
            label_text="B:$(pad_num "$backnum"), F:$(pad_num "$forenum")"
            colr "$(pad_text "$label_text" "$colwidth")" "$forenum" "$backnum"
            if (( cnt == columncnt )); then
                printf "\n"
                let cnt=1
            else
                let cnt+=1
                ((forecnt < fore_total)) && printf "|"
            fi
        done
        let forecnt=0
        let cnt=1
        printf "\n"
    done
}

function print_usage {
    # Show usage reason if first arg is available.
    [[ -n "$1" ]] && echo -e "\n$1\n"

    echo "$appname v. $appversion

    Usage:
        $appscript -h | -v
        $appscript [-2 | -n]
        $appscript FORE_START [FORE_END] [BACK_START] [BACK_END]

    Options:
        FORE_START    : Starting number for fore color range.
        FORE_END      : Ending number for fore color range.
                        Default: 255
        BACK_START    : Starting number for back color range.
                        Default: 0
        BACK_END      : Ending number for back color range.
                        Default: 255
        -h,--help     : Show this message.
        -2,--256      : Use 0-255 instead of names.
        -n,--names    : Use all named colors. This is the default.
        -v,--version  : Show $appname version and exit.
    "
}

function run_tests {
    # Run any/all test functions.
    local tests testcmd errs=0
    declare -a tests=(
        "test_escape_code_repr"
    )
    # Global test count.
    let test_count="${#tests[@]}"
    for testcmd in "${tests[@]}"; do
        printf "%s " "$testcmd"
        if $testcmd; then
            printf "...%s\n" "$(colr " passed" "green")"
        else
            printf "...%s\n" "$(colr " failed" "red")"
            let errs+=1
        fi
    done
    return $errs
}

function test_escape_code_repr {
    local s='\033[38;5;242mtest\033[39m'
    local output
    output="$(escape_code_repr "$(echo -e "$s")")" || return 1
    [[ "$output" == "$s" ]] || return 1
    return 0
}

declare -a ranges
do_256=0
do_test=0
for arg; do
    case "$arg" in
        "-2"|"--256" )
            do_256=1
            ;;
        "-h"|"--help" )
            print_usage ""
            exit 0
            ;;
        "-n"|"--names" )
            do_256=0
            ;;
        "-t"|"--test" )
            do_test=1
            ;;
        "-v"|"--version" )
            echo -e "$appname v. $appversion\n"
            exit 0
            ;;
        -*)
            print_usage "Unknown flag argument: $arg"
            exit 1
            ;;
        *)
            ranges=("${ranges[@]}" "$arg")
    esac
done

if ((do_test)); then
    # Actual count is set in `run_tests`.
    let test_count=0
    run_tests
    let errs=$?
    ((errs)) && {
        printf "\n%s: %s/%s\n" "$(colr "Failures" "red")" "$errs" "$test_count"
        exit 1
    }
    printf "\n%s (%s/%s).\n" "$(colr "All tests passed" "green")" "$test_count" "$test_count"
    exit 0
elif ((${#ranges[@]} > 0)); then
    # User has passed some range args.
    print_ranges "${ranges[0]:-0}" "${ranges[1]:-255}" "${ranges[2]:-0}" "${ranges[3]:-255}"
elif ((do_256)); then
    print_ranges
else
    print_named
fi
exit
