#!/bin/bash
# ingests csv, and writes (and possibly executes) a gnuplot script which in turn writes an .eps file
# example: cat stuff.csv | ./csv2lineplot.sh title 'Plot of ducks vs x' xlabel 'Position on x axis' ylabel 'Ducks'
set -euo pipefail

# if stdout is a tty, gnuplot is in the path, and pstopdf is in the path (indicating likely Apple)...
if [ -t 1 ] && command -v gnuplot 1>/dev/null && command -v pstopdf 1>/dev/null; then
# then redirect stdout through gnuplot and pstopdf and open in Preview
    exec 1> >(gnuplot > /tmp/out.eps && pstopdf /tmp/out.eps && open /tmp/out.pdf);
fi

TITLE=
XLABEL='label your x axis'
YLABEL='label your y axis'
XTICK=
YTICK=
SCATTER=0


while (( "$#" )); do
  case "$1" in
    title) TITLE=$2; shift 2 ;;
    xlabel) XLABEL=$2; shift 2 ;;
    ylabel) YLABEL=$2; shift 2 ;;
    xtick) XTICK=$2; shift 2 ;;
    ytick) YTICK=$2; shift 2 ;;
    scatter) SCATTER=$2; shift 2 ;;
    *) printf "warning: unrecognized argument %s\n" $1 >&2; shift ;;
  esac
done

# write the gnuplot script
printf "set terminal postscript eps enhanced font 'Helvetica' 20 size 7.5, 4.5\n"
printf "set border lw 1.5\n"
printf "set key off\n"
printf "set grid\n"
printf "set title '%s'\n" "${TITLE}"
printf "set xlabel '%s'\n" "${XLABEL}"
printf "set ylabel '%s'\n" "${YLABEL}"
printf "set xtics %s\n" "${XTICK}"
printf "set ytics %s\n" "${YTICK}"
printf "set datafile separator ','\n"

printf "plot '-' using 1:2 "

if [ $SCATTER -ne 0 ]; then
    printf "pt 7 ps 0.7\n"
else
    printf "with lines ls 1 lw 3\n"
fi

# pass through the csv data
cat -
