---
layout: post
title: Better Jekyll automated post creation with Thor
excerpt: ""
cover_image: false
comments: true
---

## What I want to achieve
Using commands can create posts easily:

```sh
$ thor post:new "Name of the post" # Create a draft post
$ thor post:publish "Name of the post" # Move the draft to _posts/ folder with today's date
$ thor post:publish "Name of the post" --date date_params # Move the draft to _posts/ folder with the date specified
```

## Installations

Add to `Gemfile`

```ruby
gem 'thor'
gem 'stringex'
```

Run `bundle` (or `bundle install`) to install new depencies.

Create `post.thor` in project's root.
