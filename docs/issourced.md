## Execute script

```
echo 'checker() { declare -p BASH_SOURCE FUNCNAME BASH_ARGV; echo "\$0=$0"; }; checker' >script.sh
bash script.sh

# declare -a BASH_SOURCE=([0]="script.sh" [1]="script.sh")
# declare -a FUNCNAME=([0]="checker" [1]="main")
# declare -a BASH_ARGV=()
# $0=script.sh
```

## Execute script with args

```
echo 'checker() { declare -p BASH_SOURCE FUNCNAME BASH_ARGV; echo "\$0=$0"; }; checker' >script.sh
bash script.sh arg1 arg2

# declare -a BASH_SOURCE=([0]="script.sh" [1]="script.sh")
# declare -a FUNCNAME=([0]="checker" [1]="main")
# declare -a BASH_ARGV=()
# $0=script.sh
```

## Source script

```
echo 'checker() { declare -p BASH_SOURCE FUNCNAME BASH_ARGV; echo "\$0=$0"; }; checker' >script.sh
. script.sh

# declare -a BASH_SOURCE=([0]="script.sh" [1]="script.sh" [2]="test_script.sh")
# declare -a FUNCNAME=([0]="checker" [1]="source" [2]="main")
# declare -a BASH_ARGV=([0]="script.sh")
# $0=test_script.sh
```

## Source script with args

```
echo 'checker() { declare -p BASH_SOURCE FUNCNAME BASH_ARGV; echo "\$0=$0"; }; checker' >script.sh
. script.sh arg1 arg2

# declare -a BASH_SOURCE=([0]="script.sh" [1]="script.sh" [2]="test_script.sh")
# declare -a FUNCNAME=([0]="checker" [1]="source" [2]="main")
# declare -a BASH_ARGV=([0]="arg2" [1]="arg1")
# $0=test_script.sh
```

## Source via bash -c

```
echo 'checker() { declare -p BASH_SOURCE FUNCNAME BASH_ARGV; echo "\$0=$0"; }; checker' >script.sh
bash -c ". script.sh"

# declare -a BASH_SOURCE=([0]="script.sh" [1]="script.sh")
# declare -a FUNCNAME=([0]="checker" [1]="source")
# declare -a BASH_ARGV=([0]="script.sh")
# $0=bash
```

## Source via bash -c with args

```
echo 'checker() { declare -p BASH_SOURCE FUNCNAME BASH_ARGV; echo "\$0=$0"; }; checker' >script.sh
bash -c ". script.sh arg1 arg2"

# declare -a BASH_SOURCE=([0]="script.sh" [1]="script.sh")
# declare -a FUNCNAME=([0]="checker" [1]="source")
# declare -a BASH_ARGV=([0]="arg2" [1]="arg1")
# $0=bash
```

## Source from function

```
echo 'checker() { declare -p BASH_SOURCE FUNCNAME BASH_ARGV; echo "\$0=$0"; }; func() { checker; }; func' >script.sh
. script.sh

# declare -a BASH_SOURCE=([0]="script.sh" [1]="script.sh" [2]="script.sh" [3]="test_script.sh")
# declare -a FUNCNAME=([0]="checker" [1]="func" [2]="source" [3]="main")
# declare -a BASH_ARGV=([0]="script.sh")
# $0=test_script.sh
```

## Source from function with args

```
echo 'checker() { declare -p BASH_SOURCE FUNCNAME BASH_ARGV; echo "\$0=$0"; }; func() { checker; }; func' >script.sh
. script.sh arg1 arg2

# declare -a BASH_SOURCE=([0]="script.sh" [1]="script.sh" [2]="script.sh" [3]="test_script.sh")
# declare -a FUNCNAME=([0]="checker" [1]="func" [2]="source" [3]="main")
# declare -a BASH_ARGV=([0]="arg2" [1]="arg1")
# $0=test_script.sh
```

## Nested source (no args)

```
echo '. b.sh' >a.sh
echo 'checker() { declare -p BASH_SOURCE FUNCNAME BASH_ARGV; echo "\$0=$0"; }; checker' >b.sh
. a.sh

# declare -a BASH_SOURCE=([0]="b.sh" [1]="b.sh" [2]="a.sh" [3]="test_script.sh")
# declare -a FUNCNAME=([0]="checker" [1]="source" [2]="source" [3]="main")
# declare -a BASH_ARGV=([0]="b.sh" [1]="a.sh")
# $0=test_script.sh
```

## Nested source with args at second level (b.sh)

```
echo '. b.sh arg1 arg2' >a.sh
echo 'checker() { declare -p BASH_SOURCE FUNCNAME BASH_ARGV; echo "\$0=$0"; }; checker' >b.sh
. a.sh

# declare -a BASH_SOURCE=([0]="b.sh" [1]="b.sh" [2]="a.sh" [3]="test_script.sh")
# declare -a FUNCNAME=([0]="checker" [1]="source" [2]="source" [3]="main")
# declare -a BASH_ARGV=([0]="a.sh")
# $0=test_script.sh
```

## Nested source with args at first level (a.sh) only

```
echo '. b.sh' >a.sh
echo 'checker() { declare -p BASH_SOURCE FUNCNAME BASH_ARGV; echo "\$0=$0"; }; checker' >b.sh
. a.sh arg1 arg2

# declare -a BASH_SOURCE=([0]="b.sh" [1]="b.sh" [2]="a.sh" [3]="test_script.sh")
# declare -a FUNCNAME=([0]="checker" [1]="source" [2]="source" [3]="main")
# declare -a BASH_ARGV=([0]="b.sh" [1]="arg2" [2]="arg1")
# $0=test_script.sh
```

## Nested source with args at both levels

```
echo '. b.sh arg1 arg2' >a.sh
echo 'checker() { declare -p BASH_SOURCE FUNCNAME BASH_ARGV; echo "\$0=$0"; }; checker' >b.sh
. a.sh arg3 arg4

# declare -a BASH_SOURCE=([0]="b.sh" [1]="b.sh" [2]="a.sh" [3]="test_script.sh")
# declare -a FUNCNAME=([0]="checker" [1]="source" [2]="source" [3]="main")
# declare -a BASH_ARGV=([0]="arg4" [1]="arg3")
# $0=test_script.sh
```

## Nested source from function (no args)

```
echo '. b.sh' >a.sh
echo 'checker() { declare -p BASH_SOURCE FUNCNAME BASH_ARGV; echo "\$0=$0"; }; func() { checker; }; func' >b.sh
. a.sh

# declare -a BASH_SOURCE=([0]="b.sh" [1]="b.sh" [2]="b.sh" [3]="a.sh" [4]="test_script.sh")
# declare -a FUNCNAME=([0]="checker" [1]="func" [2]="source" [3]="source" [4]="main")
# declare -a BASH_ARGV=([0]="b.sh" [1]="a.sh")
# $0=test_script.sh
```

## Nested source from function with args at second level

```
echo '. b.sh arg1 arg2' >a.sh
echo 'checker() { declare -p BASH_SOURCE FUNCNAME BASH_ARGV; echo "\$0=$0"; }; func() { checker; }; func' >b.sh
. a.sh

# declare -a BASH_SOURCE=([0]="b.sh" [1]="b.sh" [2]="b.sh" [3]="a.sh" [4]="test_script.sh")
# declare -a FUNCNAME=([0]="checker" [1]="func" [2]="source" [3]="source" [4]="main")
# declare -a BASH_ARGV=([0]="a.sh")
# $0=test_script.sh
```

## Nested source from function with args at first level

```
echo '. b.sh' >a.sh
echo 'checker() { declare -p BASH_SOURCE FUNCNAME BASH_ARGV; echo "\$0=$0"; }; func() { checker; }; func' >b.sh
. a.sh arg1 arg2

# declare -a BASH_SOURCE=([0]="b.sh" [1]="b.sh" [2]="b.sh" [3]="a.sh" [4]="test_script.sh")
# declare -a FUNCNAME=([0]="checker" [1]="func" [2]="source" [3]="source" [4]="main")
# declare -a BASH_ARGV=([0]="b.sh" [1]="arg2" [2]="arg1")
# $0=test_script.sh
```

## Nested source from function with args at both levels

```
echo '. b.sh arg1 arg2' >a.sh
echo 'checker() { declare -p BASH_SOURCE FUNCNAME BASH_ARGV; echo "\$0=$0"; }; func() { checker; }; func' >b.sh
. a.sh arg3 arg4

# declare -a BASH_SOURCE=([0]="b.sh" [1]="b.sh" [2]="b.sh" [3]="a.sh" [4]="test_script.sh")
# declare -a FUNCNAME=([0]="checker" [1]="func" [2]="source" [3]="source" [4]="main")
# declare -a BASH_ARGV=([0]="arg4" [1]="arg3")
# $0=test_script.sh
```
