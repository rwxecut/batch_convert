#!/bin/sh

trap ctrl_c INT

function ctrl_c() {
	printf "\nInterrupted...\n"
        exit 255
}

cmd_name=$0
recur="-maxdepth 1"

function usage
{
  printf "\nUsage: ${cmd_name} <parameters> <path>\n \
\nThe list of parameters:\n \
  -h               print this help and exit (optional);\n \
  -r               scan <path> subdirectories\n \
                   recursively (optional);\n \
  -E <extension>   input file extension;\n \
  -e <extension>   output file extension;\n \
  -b <bitrate>     output file bitrate;\n \
  -c <codec>       output file codec;\n \
\n"
}

while getopts "hrE:e:b:c:" opt; do
  case $opt in
    h) usage
       exit 0
    ;;
    r) recur=""
    ;;
    E) in_ext="$OPTARG"
    ;;
    e) out_ext="$OPTARG"
    ;;
    b) out_bitrate="$OPTARG"
    ;;
    c) out_codec="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

shift $(expr $OPTIND - 1)
path="$1"

x="notempty"
if [ -z ${in_ext+x} ] ||
   [ -z ${out_ext+x} ] ||
   [ -z ${out_bitrate+x} ] ||
   [ -z ${out_codec+x} ] ||
   [ -z ${path+x} ]; then
  usage
  exit 0
fi;

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

findcmd=$(find "${path}" ${recur} -type f -name \*.${in_ext})
IFS=$'\n'
for i in $findcmd; do
    out_filename="${i%.${in_ext}}.${out_ext}"
    echo -n "$i -> $out_filename "
    ffmpeg -y -i "$i" -vn -sn -c:a $out_codec -b:a $out_bitrate "$out_filename" &>/dev/null
    conv_result=$?
    if [ $conv_result -ne 0 ]; then
	echo -e "${RED}ERROR: ffmpeg returned $conv_result.${NC}"
    else
	echo -e "${GREEN}OK.${NC}"
    fi
    done
exit 0;

