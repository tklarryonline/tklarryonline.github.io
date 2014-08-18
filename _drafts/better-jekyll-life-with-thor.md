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

## Adding new behaviors

### Open the new post in your favorite editor

After creating a post, I usually open it in my favorite editor (which is `vim`) to start writing it.

Let's also add that requirement to our `post.thor`:

{% highlight ruby linenos %}
require 'stringex'

class Post < Thor

  # ...
  option :editor, default: "vim"
  option :open_editor, aliases: "-o", default: false, type: :boolean
  def new(*title)
    # ...
    system(options[:editor], filename) if options[:open_editor]
  end
end
{% endhighlight %}

Now use the two new options:

```sh
# Create a draft "No Editor" without open it in the default editor - 'vim'
$ thor post:new "No Editor"

# Create the post and open it with our default editor, which is 'vim'
$ thor post:new "Hello default text editor" -o

# Create the post and open it with our specified editor which is Sublime Text 2
$ thor post:new "Hello Sublime!" -o --editor=subl
```
