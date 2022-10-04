#!/bin/bash
# ingests a csv file containing values from 0 to 255 representing white to black pixel values
# first lines of the file will correspond to the top row of the resulting image
# i.e. top to bottom is oldest to newest data
set -euo pipefail

# if stdout is a tty, and pstopdf is in the path (indicating likely Apple)...
if [ -t 1 ] && command -v pstopdf 1>/dev/null; then
# then redirect stdout to a temporary file and open in Preview
    exec 1> >(cat > /tmp/out.pgm && open -a Preview /tmp/out.pgm);
fi

tmpfile=$(mktemp)
awk -F',' '{ for (i = 1; i < NF; i++) { printf (255 - $i)" " }; printf "\n" }' > $tmpfile
printf "P2\n"
printf "%s %s\n" $(head -n1 <$tmpfile | wc -w) $(wc -l <$tmpfile)
printf "255\n"
exec 0<$tmpfile
rm $tmpfile
cat
