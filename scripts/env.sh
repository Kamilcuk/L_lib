export PATH=$PATH:$PWD
sh=$(ps | tail -n 4 | sed -E '2,$d;s/.* (.*)/\1/')
echo "loading $sh"
for i in ./complete*.sh; do
	eval "$( "${i##./}" "--L_argparse_complete_$sh" | tee /dev/stderr )"
done
