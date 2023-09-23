#!/bin/bash

# Check if there are not exactly 2 command-line arguments
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <repository_name e.g. ex00> <class e.g. C05>"
  exit 1
fi

# Assign the first argument to REPO_NAME and second argument to CLASS
REPO_NAME="$1"
CLASS="$2"

# Clone the specified repository
git clone "git@github.com:nus-cs1010-2324-s1/${REPO_NAME}-grading"

# Initialize and update submodules within the cloned repository
cd "${REPO_NAME}-grading" || exit 1
git submodule init
git submodule update

# Change directory to lab-scripts
cd lab-scripts || exit 1

# Use egrep to filter lines containing the second argument from EVERYONE and save the result to CLASS
egrep "${CLASS}" EVERYONE > CLASS

# Run the remaining scripts with the CLASS file
bash clone.sh CLASS
bash compile.sh CLASS
bash test.sh CLASS

# Create report
cd ..
bash gen-report.sh lab-scripts/CLASS

# Submit to both students and prof
cd lab-scripts || exit 1
bash release.sh CLASS "Release of marks for ${REPO_NAME}"
bash push.sh "${CLASS}"

# Prints out github URL repositories of students' exercises for commenting
bash ls-submit.sh CLASS

# Prints out explain.md files showing warnings
for file in "../${CLASS}/reports/*-explain.md"; do
  if [ -f "$file" ]; then
    student_id=$(basename "$file" | cut -d '-' -f 1)
    echo "$student_id"
    cat "$file"
  fi
done
