Handy table of Bash expansions.

`null` means set and empty, like `var=""`.

Parameter is set to the string parameter `parameter="parameter"`.


| What               | Parameter  | Result               |
|--------------------|------------|----------------------|
| ${parameter-word}  | unset      | word                 |
| ${parameter-word}  | null       | parameter            |
| ${parameter-word}  | set nonull | parameter            |
| ${parameter:-word} | unset      | word                 |
| ${parameter:-word} | null       | word                 |
| ${parameter:-word} | set nonull | parameter            |
| ${parameter+word}  | unset      | nothing              |
| ${parameter+word}  | null       | word                 |
| ${parameter+word}  | set nonull | word                 |
| ${parameter:+word} | unset      | nothing              |
| ${parameter:+word} | null       | nothing              |
| ${parameter:+word} | set nonull | word                 |
| ${parameter?word}  | unset      | echo word >&2;exit 1 |
| ${parameter?word}  | null       | parameter            |
| ${parameter?word}  | set nonull | parameter            |
| ${parameter:?word} | unset      | echo word >&2;exit 1 |
| ${parameter:?word} | null       | echo word >&2;exit 1 |
| ${parameter:?word} | set nonull | parameter            |
