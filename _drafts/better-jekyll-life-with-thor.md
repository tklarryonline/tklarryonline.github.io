---
layout: post
title: Better Jekyll automated post creation with Thor
excerpt: ""
cover_image: false
comments: true
---

## What I want to achieve

Using command can create posts easily:

```sh
# Create a draft post: Jekyll life with Thor
$ thor post:new "Jekyll life with Thor"
```

This command will create a draft post with these contents:

```yaml
---
layout: post
title: Jekyll life with Thor
cover_image: false
comments: true
---
```

## Installations

Add to `Gemfile`

{% highlight ruby linenos %}
gem 'thor'
gem 'stringex'
{% endhighlight %}

Run `bundle` (or `bundle install`) to install new depencies.

## Creating new post automatically

Create `post.thor` in project's root with the following contents

{% highlight ruby linenos %}
require 'stringex'

class Post < Thor

  desc "new", "Creates a new post"
  option :comments, default: true, type: :boolean
  option :cover_image, default: false, type: :boolean
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
      post.puts "cover_image: #{options[:cover_image]}"
      post.puts "comments: #{options[:comments]}"
      post.puts "---"
    end

    puts "Created new draft post: #{filename}"
  end
end
{% endhighlight %}

Now you can run the desire command `thor post:new` and watch it works.
```
