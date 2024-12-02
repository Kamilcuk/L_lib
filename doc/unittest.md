# `L_unittest`

Simple unittesting library that does simple comparison.

<!-- vim-markdown-toc GFM -->

* [Usage example:](#usage-example)
* [Functions:](#functions)

<!-- vim-markdown-toc -->

# Usage example:

```
TEST_1() {
  local str
  str=$(echo str)
  L_unittest_eq "$str" str
}

TEST_2() {
  local str2
  str2=$(echo str2)
  L_unittest_vareq str2 str2
}

# Run all functions starting with TEST_
L_unittest_main -P TEST_
```

# Functions:

See https://kamilcuk.github.io/L_lib/#unittest for list of functions.
