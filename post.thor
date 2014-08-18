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
