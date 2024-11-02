#!/bin/bash
# @yaml
# docstring: Custom editing tool for viewing, creating and editing files
# arguments:
#   command:
#     type: string
#     required: true
#     description: Operation to perform (view/create/str_replace/insert)
#   path:
#     type: string
#     required: true
#     description: Absolute path to target file

str_replace_editor() {
    command="$1"
    path="$2"
    
    # Validate absolute path
    if [[ "$path" != /* ]]; then
        echo "Error: Path must be absolute"
        return 1
    fi
    
    case "$command" in
        "view")
            if [ -d "$path" ]; then
                find "$path" -maxdepth 2 -not -path '*/\.*' -printf '%d %p\n' | sort -n | cut -d' ' -f2-
            elif [ -f "$path" ]; then
                cat -n "$path"
            else
                echo "Error: Path does not exist"
                return 1
            fi
            ;;
            
        "create")
            if [ -e "$path" ]; then
                echo "Error: File already exists"
                return 1
            fi
            mkdir -p "$(dirname "$path")"
            echo "$3" > "$path"
            echo "File created successfully"
            ;;
            
        "str_replace")
            old_str="$3"
            new_str="$4"
            
            # Count matches
            matches=$(grep -F "$old_str" "$path" | wc -l)
            if [ $matches -eq 0 ]; then
                echo "Error: No matches found"
                return 1
            elif [ $matches -gt 1 ]; then
                echo "Error: Multiple matches found ($matches). Please provide more context."
                return 1
            fi
            
            # Create backup
            cp "$path" "${path}.bak"
            
            # Perform replacement
            sed -i "s|$old_str|$new_str|" "$path"
            echo "Replacement successful"
            ;;
            
        "insert")
            line_num="$3"
            content="$4"
            
            # Validate line number
            total_lines=$(wc -l < "$path")
            if ! [[ "$line_num" =~ ^[0-9]+$ ]] || [ "$line_num" -gt "$total_lines" ]; then
                echo "Error: Invalid line number"
                return 1
            fi
            
            sed -i "${line_num}a${content}" "$path"
            echo "Insertion successful"
            ;;
            
        *)
            echo "Error: Unknown command"
            return 1
            ;;
    esac
}