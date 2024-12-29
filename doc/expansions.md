| what               | parameter  | result               |
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
| ${parameter?word}  | unset      | parameter            |
| ${parameter:?word} | unset      | echo word >&2;exit 1 |
| ${parameter:?word} | null       | echo word >&2;exit 1 |
| ${parameter:?word} | unset      | parameter            |
