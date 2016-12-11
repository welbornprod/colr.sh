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
fore[black]=0
fore[red]=1
fore[green]=2
fore[yellow]=3
fore[blue]=4
fore[magenta]=5
fore[cyan]=6
fore[white]=7
# fore[reset] will be the code to reset all colors.
# The same is done for the `back` array.
```

They also have convenient names for the lighter versions. Just prepend `light`
to an existing name:

```bash
# This is the same as: 
# echo -e "$(colr "This is a test" "lightblue")"
echo -e "${fore[lightblue]}This is a test.${fore[reset]}"
```

### Style

The `style` array has style names for keys.

```bash
style[reset]=0
style[bright]=1
style[dim]=2
style[italic]=3
style[underline]=4
style[flash]=5
style[highlight]=7
style[normal]=22
```

### Raw Escape Code Example Usage

```bash
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
# Build the same escape code found in ${fore[125]}.
escapecode="$(extforeformat 125)"
```
