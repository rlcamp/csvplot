#!/bin/bash
# ingests a csv file containing values from 0 to 255 representing white to black pixel values
# first lines of the file will correspond to the top row of the resulting image
# i.e. top to bottom is oldest to newest data
set -euo pipefail

# if stdout is a tty, and pstopdf is in the path (indicating likely Apple)...
if [ -t 1 ] && command -v pstopdf 1>/dev/null; then
# then redirect stdout to a temporary file and open in Preview
    exec > >(cat > /tmp/out.pgm && open -a Preview /tmp/out.pgm);
fi

tmpfile=$(mktemp)

# make as many copies of the fd as we need once-through reads/writes, because each can't be rewound
exec 3>$tmpfile
exec 4<$tmpfile
exec 5<$tmpfile
exec 6<$tmpfile

# and delete the file. if the script dies abnormally for any reason, we don't leave anything behind
rm $tmpfile

# ingest input until eof
cat >&3

# write a pgm header that needs to know the number of rows and cols
printf "P5\n"
printf "%d %d\n" $(head -n1 <&4 | awk -F',' '{print NF}') $(wc -l <&5)
printf "255\n"

# pass through the entire input, removing commas and mapping 0-255 text vals onto 255-0 raw bytes
exec awk -F',' '{ for (i = 1; i <= NF; i++) printf "%c", 255 - $i }' <&6
