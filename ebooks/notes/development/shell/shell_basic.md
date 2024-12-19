# Shell Basic

## Shell Knowledge Points
+ Loop over json array using jq  
    ```sh
    sample='[{"name":"foo"},{"name":"bar"}]'
    for row in $(echo "${sample}" | jq -r '.[] | @base64'); do
        _jq() {
        echo ${row} | base64 --decode | jq -r ${1}
        }
    echo $(_jq '.name')
    done
    ```  
    > https://www.starkandwayne.com/blog/bash-for-loop-over-json-array-using-jq/index.html  

