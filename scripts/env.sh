export PATH=$PATH:$PWD
sh=$(ps | tail -n 4 | sed -E '2,$d;s/.* (.*)/\1/')
echo "loading $sh"
eval "$(completetest2.sh "--L_argparse_complete_$sh" | tee /dev/stderr)"
eval "$(completetest.sh "--L_argparse_complete_$sh" | tee /dev/stderr)"
