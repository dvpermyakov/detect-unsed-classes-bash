#!/bin/bash

# path where java and kotlin files will be searching
path=$PWD
# max occurrence of java or kotlin class to consider be unused
max_occurrence="2"

# parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -m|--max)
      max_occurrence="$2"
      shift # past argument
      shift # past value
      ;;
    -p|--path)
      path="$2"
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

# java and kotlin class paths
file_class_path="../class_path.txt"
# results
file_results="../results.txt"

# clear files
truncate -s 0 $file_class_path
truncate -s 0 $file_results

# write all kotlin and java class paths to temp file
find "$path" -type f -name '*.kt' -or -name '*.java' >$file_class_path

# write unused class names to results file
while IFS= read -r class_path; do
  class_name=$(basename "${class_path%.*}")
  result=$(grep -l -R "$class_name" .)
  count=$(echo "$result" | wc -l | xargs)
  if [[ "$count" -le max_occurrence ]]; then
    printf "Class %s uses:\n%s\n\n" "$class_name" "$result" >>$file_results
  fi
done <$file_class_path

# clear temp file
rm -rf "$file_class_path"
