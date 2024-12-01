
set -xeuo pipefail

printf -v asctime "%()T" -1
filename=${BASH_SOURCE[0]:-}
funcName=${FUNCNAME[0]:-}
levelname=INFO
name=${BASH_SOURCE[0]##*/}
pathname=${BASH_SOURCE[0]}
color=
reset=
echo "$filename $funcName $asctime"
message='hello world'
L_log_format='${color}${levelname}:${name}:${message}'
eval "read -r msg <<EOF
$L_log_format$reset
EOF"
echo "$msg"


