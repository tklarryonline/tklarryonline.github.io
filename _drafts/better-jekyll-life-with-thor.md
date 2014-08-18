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
```

## Installations

Add to `Gemfile`

```ruby
gem 'thor'
gem 'stringex'
```

Run `bundle` (or `bundle install`) to install new depencies.

Create `post.thor` in project's root with the following contents

```ruby
require 'stringex'

class Post < Thor

  desc "new", "Creates a new post"
  method_option :editor, default: "subl"
  def new(*title)
    title = title.join(" ")
    layout = 'post'
    filename = "_drafts/#{title.to_url}.md"

    if File.exists?(filename)
      abort("#{filename} already exists!")
    end

    puts "Creating new post: #{filename}"

    open(filename, 'w') do |post|
      post.puts "---"
      post.puts "layout: #{layout}"
      post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
      post.puts "---"
    end

    system(options[:editor], filename)
  end
end
```
