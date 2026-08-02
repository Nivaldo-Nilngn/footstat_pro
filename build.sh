#!/bin/bash
set -e

if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable
fi

export PATH="$PATH:`pwd`/flutter/bin"

flutter config --no-analytics
flutter pub get
flutter build web --release
