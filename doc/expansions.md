| what               | parameter  | result    |
|--------------------|------------|-----------|
| ${parameter-word}  | unset      | word      |
| ${parameter-word}  | null       | parameter |
| ${parameter-word}  | set nonull | parameter |
| ${parameter:-word} | unset      | word      |
| ${parameter:-word} | null       | word      |
| ${parameter:-word} | set nonull | parameter |
| ${parameter+word}  | unset      | nothing   |
| ${parameter+word}  | null       | word      |
| ${parameter+word}  | set nonull | word      |
| ${parameter:+word} | unset      | nothing   |
| ${parameter:+word} | null       | nothing   |
| ${parameter:+word} | set nonull | word      
|
