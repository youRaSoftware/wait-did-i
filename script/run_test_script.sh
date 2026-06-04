#!/bin/bash
cd ../
runTest() {
  dirPath=$(dirname "$1")
  cd "$dirPath" || return
  if [ -f "pubspec.yaml" ]; then
    if [ -d "test" ]; then
    echo "Running tests in $dirPath"
    rm -rf coverage
    if [ "$dirpath" == "./data" ]; then
      flutter test --coverage
    else
      flutter test --coverage
    fi
    results="
    }results.txt"
    path="${dirPath#./}"
    path="${path//\//\\/}"
    echo "path $path"
    sed -e "s/lib\//"$path"\/lib\//g" "coverage/lcov.info" > "$results"
    cat "$results" >> "$(dirname "$0")/../coverage/lcov.info"
    rm "$results"
    fi
  fi
  cd - >/dev/null || return
}

listDirs=$(find . -name "pubspec.yaml" -not -path "./.flutter.git/*")
rm -rf coverage
mkdir "coverage"
for file in $listDirs; do
    runTest "$file"
done

echo "All tests passed"
sed -i -e 's/[[:space:]]/\n/g' 'coverage/lcov.info'
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html



