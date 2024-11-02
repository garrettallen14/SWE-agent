#!/bin/bash
# @yaml
# docstring: Execute bash commands in the container
# arguments:
#   command:
#     type: string
#     required: true
#     description: The bash command to run

bash_tool() {
    # Create temp file for output
    tmp_output=$(mktemp)
    
    # Run command and capture output
    eval "$1" 2>&1 | tee "$tmp_output"
    exit_code=${PIPESTATUS[0]}
    
    # Check output size and truncate if needed
    output_size=$(wc -l < "$tmp_output")
    if [ $output_size -gt 1000 ]; then
        head -n 500 "$tmp_output"
        echo "<response clipped>"
        tail -n 500 "$tmp_output"
    else
        cat "$tmp_output"
    fi
    
    rm "$tmp_output"
    return $exit_code
}