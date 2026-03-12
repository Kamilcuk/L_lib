Handy table of Bash expansions.

Use cases:

- Default values: `${var:-default}` (assigns `default` if `var` is unset or empty)
- Alternate value if set: `${var:+alternate}` (returns `alternate` if `var` is set and not empty)
- `if (( ${array[*]+1} )); then` - checking if array is not empty under old bash with set -u
- `if (( ${array[*]+${#array[*]}}+0 > SOME_VALUE )); then` - getting the number of array elements under old bash with set -u

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

For arrays:

| What                | array       | $# | Result               |
| ------------------- | ----------- | ---| -------------------- |
| "${array[@]-word}"  | unset       | 1  | word                 |
| "${array[@]-word}"  | array=()    | 1  | word                 |
| "${array[@]-word}"  | array=('')  | 1  | ''                   |
| "${array[@]-word}"  | array=(val) | 1  | val                  |
| "${array[@]:-word}" | unset       | 1  | word                 |
| "${array[@]:-word}" | array=()    | 1  | word                 |
| "${array[@]:-word}" | array=('')  | 1  | word                 |
| "${array[@]:-word}" | array=(val) | 1  | val                  |
| "${array[@]+word}"  | unset       | 0  |                      |
| "${array[@]+word}"  | array=()    | 0  |                      |
| "${array[@]+word}"  | array=('')  | 1  | word                 |
| "${array[@]+word}"  | array=(val) | 1  | word                 |
| "${array[@]:+word}" | unset       | 0  |                      |
| "${array[@]:+word}" | array=()    | 0  |                      |
| "${array[@]:+word}" | array=('')  | 0  |                      |
| "${array[@]:+word}" | array=(val) | 1  | word                 |
| "${array[@]?word}"  | unset       | -- | echo word >&2;exit 1 |
| "${array[@]?word}"  | array=()    | -- | echo word >&2;exit 1 |
| "${array[@]?word}"  | array=('')  | 1  | ''                   |
| "${array[@]?word}"  | array=(val) | 1  | val                  |
| "${array[@]:?word}" | unset       | -- | echo word >&2;exit 1 |
| "${array[@]:?word}" | array=()    | -- | echo word >&2;exit 1 |
| "${array[@]:?word}" | array=('')  | -- | echo word >&2;exit 1 |
| "${array[@]:?word}" | array=(val) | 1  | val                  |
| "${array[*]-word}"  | unset       | 1  | word                 |
| "${array[*]-word}"  | array=()    | 1  | word                 |
| "${array[*]-word}"  | array=('')  | 1  | ''                   |
| "${array[*]-word}"  | array=(val) | 1  | val                  |
| "${array[*]:-word}" | unset       | 1  | word                 |
| "${array[*]:-word}" | array=()    | 1  | word                 |
| "${array[*]:-word}" | array=('')  | 1  | word                 |
| "${array[*]:-word}" | array=(val) | 1  | val                  |
| "${array[*]+word}"  | unset       | 1  | ''                   |
| "${array[*]+word}"  | array=()    | 1  | ''                   |
| "${array[*]+word}"  | array=('')  | 1  | word                 |
| "${array[*]+word}"  | array=(val) | 1  | word                 |
| "${array[*]:+word}" | unset       | 1  | ''                   |
| "${array[*]:+word}" | array=()    | 1  | ''                   |
| "${array[*]:+word}" | array=('')  | 1  | ''                   |
| "${array[*]:+word}" | array=(val) | 1  | word                 |
| "${array[*]?word}"  | unset       | -- | echo word >&2;exit 1 |
| "${array[*]?word}"  | array=()    | -- | echo word >&2;exit 1 |
| "${array[*]?word}"  | array=('')  | 1  | ''                   |
| "${array[*]?word}"  | array=(val) | 1  | val                  |
| "${array[*]:?word}" | unset       | -- | echo word >&2;exit 1 |
| "${array[*]:?word}" | array=()    | -- | echo word >&2;exit 1 |
| "${array[*]:?word}" | array=('')  | -- | echo word >&2;exit 1 |
| "${array[*]:?word}" | array=(val) | 1  | val                  |
| "${array[@]-"word1" "word2"}"  | unset         | 1  | word1\ word2         |
| "${array[@]-"word1" "word2"}"  | array=()      | 1  | word1\ word2         |
| "${array[@]-"word1" "word2"}"  | array=('')    | 1  | ''                   |
| "${array[@]-"word1" "word2"}"  | array=(val)   | 1  | val                  |
| "${array[@]-"word1" "word2"}"  | array=('' '') | 2  | '' ''                |
| "${array[@]:-"word1" "word2"}" | unset         | 1  | word1\ word2         |
| "${array[@]:-"word1" "word2"}" | array=()      | 1  | word1\ word2         |
| "${array[@]:-"word1" "word2"}" | array=('')    | 1  | word1\ word2         |
| "${array[@]:-"word1" "word2"}" | array=(val)   | 1  | val                  |
| "${array[@]:-"word1" "word2"}" | array=('' '') | 2  | '' ''                |
| "${array[@]+"word1" "word2"}"  | unset         | 0  |                      |
| "${array[@]+"word1" "word2"}"  | array=()      | 0  |                      |
| "${array[@]+"word1" "word2"}"  | array=('')    | 1  | word1\ word2         |
| "${array[@]+"word1" "word2"}"  | array=(val)   | 1  | word1\ word2         |
| "${array[@]+"word1" "word2"}"  | array=('' '') | 1  | word1\ word2         |
| "${array[@]:+"word1" "word2"}" | unset         | 0  |                      |
| "${array[@]:+"word1" "word2"}" | array=()      | 0  |                      |
| "${array[@]:+"word1" "word2"}" | array=('')    | 0  |                      |
| "${array[@]:+"word1" "word2"}" | array=(val)   | 1  | word1\ word2         |
| "${array[@]:+"word1" "word2"}" | array=('' '') | 1  | word1\ word2         |
| "${array[@]?"word1" "word2"}"  | unset         | -- | echo word >&2;exit 1 |
| "${array[@]?"word1" "word2"}"  | array=()      | -- | echo word >&2;exit 1 |
| "${array[@]?"word1" "word2"}"  | array=('')    | 1  | ''                   |
| "${array[@]?"word1" "word2"}"  | array=(val)   | 1  | val                  |
| "${array[@]?"word1" "word2"}"  | array=('' '') | 2  | '' ''                |
| "${array[@]:?"word1" "word2"}" | unset         | -- | echo word >&2;exit 1 |
| "${array[@]:?"word1" "word2"}" | array=()      | -- | echo word >&2;exit 1 |
| "${array[@]:?"word1" "word2"}" | array=('')    | -- | echo word >&2;exit 1 |
| "${array[@]:?"word1" "word2"}" | array=(val)   | 1  | val                  |
| "${array[@]:?"word1" "word2"}" | array=('' '') | 2  | '' ''                |
| ${array[@]-"word1" "word2"}  | unset         | 2  | word1 word2          |
| ${array[@]-"word1" "word2"}  | array=()      | 2  | word1 word2          |
| ${array[@]-"word1" "word2"}  | array=('')    | 0  |                      |
| ${array[@]-"word1" "word2"}  | array=(val)   | 1  | val                  |
| ${array[@]-"word1" "word2"}  | array=('' '') | 0  |                      |
| ${array[@]:-"word1" "word2"} | unset         | 2  | word1 word2          |
| ${array[@]:-"word1" "word2"} | array=()      | 2  | word1 word2          |
| ${array[@]:-"word1" "word2"} | array=('')    | 2  | word1 word2          |
| ${array[@]:-"word1" "word2"} | array=(val)   | 1  | val                  |
| ${array[@]:-"word1" "word2"} | array=('' '') | 0  |                      |
| ${array[@]+"word1" "word2"}  | unset         | 0  |                      |
| ${array[@]+"word1" "word2"}  | array=()      | 0  |                      |
| ${array[@]+"word1" "word2"}  | array=('')    | 2  | word1 word2          |
| ${array[@]+"word1" "word2"}  | array=(val)   | 2  | word1 word2          |
| ${array[@]+"word1" "word2"}  | array=('' '') | 2  | word1 word2          |
| ${array[@]:+"word1" "word2"} | unset         | 0  |                      |
| ${array[@]:+"word1" "word2"} | array=()      | 0  |                      |
| ${array[@]:+"word1" "word2"} | array=('')    | 0  |                      |
| ${array[@]:+"word1" "word2"} | array=(val)   | 2  | word1 word2          |
| ${array[@]:+"word1" "word2"} | array=('' '') | 2  | word1 word2          |
| ${array[@]?"word1" "word2"}  | unset         | -- | echo word >&2;exit 1 |
| ${array[@]?"word1" "word2"}  | array=()      | -- | echo word >&2;exit 1 |
| ${array[@]?"word1" "word2"}  | array=('')    | 0  |                      |
| ${array[@]?"word1" "word2"}  | array=(val)   | 1  | val                  |
| ${array[@]?"word1" "word2"}  | array=('' '') | 0  |                      |
| ${array[@]:?"word1" "word2"} | unset         | -- | echo word >&2;exit 1 |
| ${array[@]:?"word1" "word2"} | array=()      | -- | echo word >&2;exit 1 |
| ${array[@]:?"word1" "word2"} | array=('')    | -- | echo word >&2;exit 1 |
| ${array[@]:?"word1" "word2"} | array=(val)   | 1  | val                  |
| ${array[@]:?"word1" "word2"} | array=('' '') | 0  |                      |
| ${array[*]-"word1" "word2"}  | unset         | 2  | word1 word2          |
| ${array[*]-"word1" "word2"}  | array=()      | 2  | word1 word2          |
| ${array[*]-"word1" "word2"}  | array=('')    | 0  |                      |
| ${array[*]-"word1" "word2"}  | array=(val)   | 1  | val                  |
| ${array[*]-"word1" "word2"}  | array=('' '') | 0  |                      |
| ${array[*]:-"word1" "word2"} | unset         | 2  | word1 word2          |
| ${array[*]:-"word1" "word2"} | array=()      | 2  | word1 word2          |
| ${array[*]:-"word1" "word2"} | array=('')    | 2  | word1 word2          |
| ${array[*]:-"word1" "word2"} | array=(val)   | 1  | val                  |
| ${array[*]:-"word1" "word2"} | array=('' '') | 0  |                      |
| ${array[*]+"word1" "word2"}  | unset         | 0  |                      |
| ${array[*]+"word1" "word2"}  | array=()      | 0  |                      |
| ${array[*]+"word1" "word2"}  | array=('')    | 2  | word1 word2          |
| ${array[*]+"word1" "word2"}  | array=(val)   | 2  | word1 word2          |
| ${array[*]+"word1" "word2"}  | array=('' '') | 2  | word1 word2          |
| ${array[*]:+"word1" "word2"} | unset         | 0  |                      |
| ${array[*]:+"word1" "word2"} | array=()      | 0  |                      |
| ${array[*]:+"word1" "word2"} | array=('')    | 0  |                      |
| ${array[*]:+"word1" "word2"} | array=(val)   | 2  | word1 word2          |
| ${array[*]:+"word1" "word2"} | array=('' '') | 2  | word1 word2          |
| ${array[*]?"word1" "word2"}  | unset         | -- | echo word >&2;exit 1 |
| ${array[*]?"word1" "word2"}  | array=()      | -- | echo word >&2;exit 1 |
| ${array[*]?"word1" "word2"}  | array=('')    | 0  |                      |
| ${array[*]?"word1" "word2"}  | array=(val)   | 1  | val                  |
| ${array[*]?"word1" "word2"}  | array=('' '') | 0  |                      |
| ${array[*]:?"word1" "word2"} | unset         | -- | echo word >&2;exit 1 |
| ${array[*]:?"word1" "word2"} | array=()      | -- | echo word >&2;exit 1 |
| ${array[*]:?"word1" "word2"} | array=('')    | -- | echo word >&2;exit 1 |
| ${array[*]:?"word1" "word2"} | array=(val)   | 1  | val                  |
| ${array[*]:?"word1" "word2"} | array=('' '') | 0  |                      |
