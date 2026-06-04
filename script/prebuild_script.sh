#!/bin/bash

cd ../
find . -name "pubspec.yaml" -not -path "./.flutter.git/*"
find . -name "pubspec.yaml" -not -path "./.flutter.git/*" -execdir flutter pub get \;
find . -name "pubspec.yaml" -not -path "./.flutter.git/*" -not -path "./features/*" -execdir dart run build_runner build --delete-conflicting-outputs \;
# generate localization keys
cd "core" || exit
dart run easy_localization:generate -f keys -o locale_keys.g.dart -O lib/localization -S resources/translations


