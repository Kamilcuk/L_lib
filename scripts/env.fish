# soo this works with Bash, Zsh and Fish !
set sh $(ps | tail -n 4 | sed -E '2,$d;s/.* (.*)/\1/')
echo "loading $2$sh"
eval "$(./completetest.sh "--L_argparse_complete_$2$sh" | tee /dev/stderr)"
eval "$(./completetest2.sh "--L_argparse_complete_$2$sh" | tee /dev/stderr)"
