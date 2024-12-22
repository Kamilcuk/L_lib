# soo this works with Bash, Zsh and Fish !
add_to_path bin
eval "$(./completetest.sh "--L_argparse_complete_fish" | tee /dev/stderr)"
eval "$(./completetest2.sh "--L_argparse_complete_fish" | tee /dev/stderr)"
