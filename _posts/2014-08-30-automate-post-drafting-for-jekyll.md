---
layout: post
class: blog-post
title: "Automate post drafting for Jekyll"
excerpt: "Thor - the God of Thunder - has come to the rescue!"
date: "2014-08-30 1:47:59"
cover_image: false
comments: true
---

Since the very first day of using Jekyll, I've always been creating post by manually create the Markdown file with those meta data:

```yaml
---
layout: post
title: "Automate post drafting for Jekyll"
excerpt: "Thor - the God of Thunder - comes to the rescue!"
cover_image: false
comments: true
---
```

This 'buffy' method could fit with a novice user whose needs are just writing and posting articles. Back then I didn't care how to use Jekyll `draft` functionality, until I needed to keep track of my drafts with Git... Manually creating drafts, finishing and publishing them to my blog starting to be a nuisance.

Thankfully, the hammer of [Thor](http://whatisthor.com/) struck down on me!

## What I want to achive

This article main purposes are to introduce you to [Thor](http://whatisthor.com/) and write a little command line task to automatically create draft with desired options using only one command:

```sh
# Creates a draft: Hello Jekyll
$ thor post:draft Hello Jekyll
```

This command will create a draft `_drafts/hello-jekyll.md` with these data:

```yaml
---
layout: post
title: "Hello Jekyll"
excerpt: ""
cover_image: false
comments: true
---
```

## How to do that?

Add the required gems to your `Gemfile`:

```ruby
gem 'thor'
gem 'stringex'
```

And run `bundle` (or `bundle install`).

Then create `post.thor` in your Jekyll's source root:

```ruby
# post.thor
require 'stringex'
require 'fileutils'

class Post < Thor
  include FileUtils

  DEFAULT_EDITOR = "vim"

  class_option :editor, default: DEFAULT_EDITOR
  class_option :open_editor, aliases: "-o", default: false, type: :boolean

  desc "draft TITLE", "Creates a new draft `TITLE` in `_drafts/`"
  option :comments, default: true, type: :boolean
  option :cover_image, default: false, type: :boolean
  def draft(*title)
    title = title.join(" ")
    layout = "post"
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
      post.puts "excerpt: \"\""
      post.puts "cover_image: #{options[:cover_image]}"
      post.puts "comments: #{options[:comments]}"
      post.puts "---"
    end

    puts "Created new draft: #{filename}"

    open_editor(filename)
  end

  private

  def open_editor(filename)
    if options[:open_editor] || options[:editor] != DEFAULT_EDITOR
      system(options[:editor], filename)
    end
  end
end
```

Now you can try your new command `thor post:draft` out and watch it works.

```sh
# Create a draft with default meta data
$ thor post:draft Hello Jekyll

# Create a draft and automatically open it in your favorite editor
# (You can change your favorite editor at line 8)
$ thor post:draft Hello Jekyll -o

# Or change your default editor and automatically open the draft
$ thor post:draft Hello Jekyll --editor=subl

# Don't want your draft to have comments enabled?
$ thor post:draft Hello Jekyll --no-comments
```

## Afterthoughts

Drafts need to be published. Using this as the starting point, you may want to write another Thor task to publish your drafts with date and time. Sooner or later, I would write another blog post about publishing drafts and refactoring my Thor tasks.

Furthermore, this post is not limited to only Jekyll. Any other static site generators that use Markdown (or text-based post) can also use Thor to improve their blogging flow.
