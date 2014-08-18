require 'stringex'

class Post < Thor

  desc "new", "Creates a new draft post"
  option :comments, default: true, type: :boolean
  option :cover_image, default: false, type: :boolean
  option :editor, default: "subl"
  option :open_editor, aliases: "-o", default: false, type: :boolean
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

    system(options[:editor], filename) if options[:open_editor]
  end
  end
end
