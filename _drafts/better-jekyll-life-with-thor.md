---
layout: post
title: Better Jekyll life with Thor
excerpt: "How I automated my Jekyll flow"
cover_image: false
comments: true
---

## What I want to achieve

Using command can create posts easily:

```sh
# Create a draft: Jekyll life with Thor
$ thor post:draft "Jekyll life with Thor"
```

This command will create a draft `_drafts/jekyll-life-with-thor.md` with these contents:

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

## Creating new draft automatically

Create `post.thor` in project's root with the following contents

{% highlight ruby linenos %}
require 'stringex'
require 'fileutils'

class Post < Thor
  include FileUtils

  desc "draft TITLE", "Creates a new draft `TITLE` in `_drafts/`"
  option :comments, default: true, type: :boolean
  option :cover_image, default: false, type: :boolean
  def draft(*title)
    title = title.join(" ")
    layout = 'post'
    filename = "_drafts/#{title.to_url}.md"

    # Create `_drafts/` if not exists
    mkdir_p "_drafts"

    if File.exists?(filename)
      abort("#{filename} already exists!")
    end

    puts "Creating new draft: #{filename}"

    open(filename, 'w') do |post|
      post.puts "---"
      post.puts "layout: #{layout}"
      post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
      post.puts "cover_image: #{options[:cover_image]}"
      post.puts "comments: #{options[:comments]}"
      post.puts "---"
    end

    puts "Created new draft: #{filename}"
  end
end
{% endhighlight %}

Now you can run the desire command `thor post:new` and watch it works.

## Adding extra behaviors

### Open the new post in your favorite editor

After creating a post, I usually open it in my favorite editor (which is `vim`) to start writing it.

Let's also add that requirement to our `post.thor`:

{% highlight ruby linenos %}
require 'stringex'
require 'fileutils'

class Post < Thor
  include FileUtils

  # ...
  option :editor, default: "vim"
  option :open_editor, aliases: "-o", default: false, type: :boolean
  def draft(*title)
    # ...
    system(options[:editor], filename) if options[:open_editor]
  end
end
{% endhighlight %}

Now use the two new options:

```sh
# Create a draft "No Editor" without open it in the default editor - 'vim'
$ thor post:draft "No Editor"

# Create a draft and open it with our default editor
$ thor post:draft "Hello default text editor" -o

# Create a draft and open it with our specified editor which is Sublime Text 2
$ thor post:draft "Hello Sublime!" -o --editor=subl
```

### Publish the draft post

In Jekyll a post is considered published should:

- Be put in the `_posts/` folder
- Be named in the exact format: `date-title.md`, ie: `2014-08-19-title.md`
- Include publishing date and time in the YAML content, ie: `date: 2014-08-19 21:33`

Let's do the first two tasks, by creating a new `publish()` function in our `post.thor`

{% highlight ruby linenos %}
require 'stringex'
require 'fileutils'

class Post < Thor
  include FileUtils

  # ...

  desc "publish FILE", "Publishes a draft `FILE`"
  option :date, default: Time.now.strftime("%Y-%m-%d")
  def publish(file=nil)
    # Create `_posts/` if not exists
    mkdir_p "_posts"

    new_filename = "_posts/#{options[:date]}-#{File.basename(file)}"
    mv file, new_filename
    puts "Published draft to #{new_filename}"
  end
end
{% endhighlight %}

Now test our new code:

```sh
# Create a draft: Hello Jekyll
$ thor post:draft "Hello Jekyll"
Creating new draft: _drafts/hello-jekyll.md
Created new draft: _drafts/hello-jekyll.md

# Publish our newly created draft
$ thor post:draft _drafts/hello-jekyll.md
Published draft to _posts/2014-08-19-hello-jekyll.md
```

But what if we forgot to enter the file name? In that case, our script should ask us to choose the desired draft in the `_drafts/` folder. Let's add that behavior to our code then:

{% highlight ruby linenos %}
require 'stringex'
require 'fileutils'

class Post < Thor
  include FileUtils

  # ...

  desc "publish FILE", "Publishes a draft `FILE`"
  option :date, default: Time.now.strftime("%Y-%m-%d")
  def publish(file=nil)
    unless file
      puts "Choose a draft to publish:"
      @files = Dir["_drafts/*"]
      @files.each_with_index { |f,i| puts "#{i+1}: #{f}" }
      print "Pick one: "
      num = STDIN.gets
      file = @files[num.to_i - 1]
      puts ""
    end

    # Create `_posts/` if not exists
    mkdir_p "_posts"

    new_filename = "_posts/#{options[:date]}-#{File.basename(file)}"
    mv file, new_filename
    puts "Published draft to #{new_filename}"
  end
end
{% endhighlight %}

This time when we run the command `thor post:draft`, we will see a nice prompt:

```sh
$ thor post:draft
Choose a draft to publish:
1: _drafts/better-jekyll-life-with-thor.md
2: _drafts/hello-jekyll.md
Pick one: 2

Published draft to _posts/2014-08-19-hello-jekyll.md
```

Now it's time to deal with the last requirement: _Include publishing date and time in the YAML content_

The flow now should be different:

- Read the draft file to the buffer
- Prepend a new line `date: date time` to the buffer, after the zero index
- Write the edited buffer to the new file in `_posts`
- Delete the old draft file

Therefore, we should change the function `publish()` to

{% highlight ruby linenos %}
require 'stringex'
require 'fileutils'

class Post < Thor
  include FileUtils

  # ...

  desc "publish FILE", "Publishes a draft `FILE`"
  option :date, default: Time.now.strftime("%Y-%m-%d")
  option :time, default: Time.now.strftime('%k:%M:%S')
  def publish(original_file=nil)
    unless original_file
      puts "Choose a draft to publish:"
      @files = Dir["_drafts/*"]
      @files.each_with_index { |f,i| puts "#{i+1}: #{f}" }
      print "Pick one: "
      num = STDIN.gets
      original_file = @files[num.to_i - 1]
      puts ""
    end

    # Creates `_posts/` if not exists
    mkdir_p "_posts"

    # Reads original draft's contents to buffer
    f = File.open(original_file, 'r+')
    lines = f.readlines

    # Prepends `date` to after zero index
    # since the zero index is always `---`
    date_yaml = "date: #{options[:date]} #{options[:time]}"
    lines.insert(1, date_yaml)

    new_filename = "_posts/#{options[:date]}-#{File.basename(original_file)}"

    if File.exists?(new_filename)
      abort("#{filename} already exists!")
    end

    # Writes buffer contents to a new file in `_posts/`
    open(new_filename, 'w') do |post|
      lines.each { |line| post.puts line }
    end

    # Deletes old file
    File.delete(original_file)

    puts "Published draft to #{new_filename}"
  end
end
{% endhighlight %}


