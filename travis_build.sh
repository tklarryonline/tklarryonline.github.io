#!/usr/bin/env bash
# This script is for use in travis-ci only.
set -e # halt script on error

# Only proceeds to deployment if this is the source branch
# and not a pull request
if [ "$TRAVIS_BRANCH" != source ] || [ "$TRAVIS_PULL_REQUEST" != false ]; then
    exit 0
fi

echo "This is the source branch. Starting deployment..."

# Makes sure git will let us push
git config --global user.email "luan@tklarryonline.me"
git config --global user.name "Luan & Travis"

source_path=`pwd`
production_path=$source_path/tklarryonline
production_repo=https://${GH_TOKEN}@${GH_REPO}

# Clones the current site to corresponding dir
git clone $production_repo --branch master --single-branch $production_path > /dev/null 2>&1

# If git clone failed
if [ $? != 0 ]; then
    echo "Cloning production repo failed!"
    exit $?
fi

# Builds my site
echo "Starting to build..."
bundle exec jekyll build --trace

# Exit with appropriate exit code if jekyll failed
if [ $? != 0 ]; then exit $?; fi

echo "Build ran correctly. Starting deployment..."

# Goes to jekyll destination
cd $production_path

# Adds all the new changes and commits them
git add -A && git commit -m "Build #$TRAVIS_BUILD_NUMBER"

# Andddd pushes!
git push origin master > /dev/null 2>&1
