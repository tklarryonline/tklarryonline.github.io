#!/usr/bin/env bash
# This script is for use in travis-ci only.

# Only proceeds to deployment if this is the source branch
# and not a pull request
if [ "$TRAVIS_BRANCH" != source ] || [ "$TRAVIS_PULL_REQUEST" != false ]; then
    echo "Jekyll build finished successfully. Your mom should be proud."
    exit 0
fi

echo "This is the source branch. Starting deployment..."

# Makes sure git will let us push
git config --global user.email "luan@tklarryonline.me"
git config --global user.name "Luan & Travis"

source_path=`pwd`
production_path=$source_path/tklarryonline
production_repo=git@github.com:tklarryonline/tklarryonline.github.io.git

# Clones the current site to corresponding dir
git clone $production_repo --branch master --single-branch $production_path

# Generate site from markdown source
jekyll build

# Exit with appropriate exit code if jekyll failed
if [ $? != 0 ]; then exit $?; fi

# Goes to jekyll destination
cd tklarryonline

# Adds all the new changes and commits them
git add -am "Build #$TRAVIS_BUILD_NUMBER"

# Andddd pushes!
git push origin master
