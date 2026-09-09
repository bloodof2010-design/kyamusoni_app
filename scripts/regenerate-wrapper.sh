#!/bin/bash
set -e

echo "Regenerating Gradle wrapper..."
cd android
rm -f gradle/wrapper/gradle-wrapper.jar
./gradlew wrapper --gradle-version 8.14.0 --distribution-type bin
cd ..

echo "Gradle wrapper regenerated successfully!"
