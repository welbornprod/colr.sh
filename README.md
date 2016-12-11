# Colr.sh

A BASH version of [Colr](https://github.com/welbornprod/colr). It provides
easy terminal colors by executing it or sourcing it into another script.

## Command Line Usage
```
Usage:
    colr.sh -h | -v
    colr.sh TEXT FORE [BACK] [STYLE]

Options:
    BACK          : Name of back color for the text.
    FORE          : Name of fore color for the text.
    STYLE         : Name of style for the text.
    TEXT          : Text to colorize.
    -h,--help     : Show this message.
    -v,--version  : Show Colr version and exit.
```

## Colors

Raw escape codes are provided through associative arrays named `fore`,
`back`, and `style`. The preferred method for using `colr.sh` is to call the
[colr](#colr) function, but the raw codes are still accessible.

### Fore/Back

The `fore` and `back` arrays have numbered keys for all 256-color codes, and
named keys for basic colors.

```bash
# Example keys/values after sourcing colr.sh.
fore[black]="\033[30m"
fore[red]="\033[31m"
fore[green]="\033[32m"
fore[yellow]="\033[33m"
fore[blue]="\033[34m"
fore[magenta]="\033[35m"
fore[cyan]="\033[36m"
fore[white]="\033[37m"
fore[reset]="\033[39m"
# The same is done for the `back` array, with the appropriate code numbers.
```

They also have convenient names for the lighter versions. Just prepend `light`
to an existing name:

```bash
source colr.sh
# This is the same as:
# echo -e "$(colr "This is a test" "lightblue")"
echo -e "${fore[lightblue]}This is a test.${fore[reset]}"
```

### Style

The `style` array has style names for keys.

```bash
# Example keys/values after sourcing colr.sh.
style[reset]="\033[0m"
style[bright]="\033[1m"
style[dim]="\033[2m"
style[italic]="\033[3m"
style[underline]="\033[4m"
style[flash]="\033[5m"
style[highlight]="\033[7m"
style[normal]="\033[22m"
```

### Raw Escape Code Example Usage

```bash
source colr.sh
echo -e "${fore[red]}${style[bright]}Test${style[reset]}"
```

## Functions

### colr
```bash
colr TEXT [FORE] [BACK] [STYLE]
```

Applies escape codes to the text and prints it to stdout for consumption.

#### Example
```bash
source colr.sh

echo "$(colr "This is a test." "blue" "white" "bright")"
```

### colr_auto_disable
```bash
colr_auto_disable
```

Automatically calls [colr_disable](#colr_disable) if output is being piped.

#### Example
```bash
source colr.sh

colr_auto_disable
echo -e "$(colr "This will not be colorized when piped." "red")"
```

### colr_enable
```bash
colr_enable
```

Enables colorized output after [colr_disable](#colr_disable) has been called.

### colr_disable
```bash
colr_disable
```

Disables colorized output until [colr_enable](#colr_enable) is called again.

### codeformat
```bash
codeformat NUMBER
```

Builds a basic escape code by number only. This is used to build the escape
code associative arrays, and is generally not needed except for that use.

#### Example
```bash
source colr.sh
# Build the same escape code found in ${fore[red]}.
escapecode="$(codeformat 31)"
```

### extbackformat
```bash
extbackformat NUMBER
```

Builds an escape code for the 256-color background colors (extended colors).
This is used to build the escape code associative arrays, and is generally
not needed except for that use.

#### Example
```bash
source colr.sh
# Build the same escape code found in ${back[155]}.
escapecode="$(extbackformat 155)"
```

### extforeformat
```bash
extforeformat NUMBER
```

Builds an escape code for the 256-color forekground colors (extended colors).
This is used to build the escape code associative arrays, and is generally
not needed except for that use.

#### Example
```bash
source colr.sh
# Build the same escape code found in ${fore[125]}.
escapecode="$(extforeformat 125)"
```
