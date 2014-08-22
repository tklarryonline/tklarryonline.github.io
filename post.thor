require 'stringex'
require 'fileutils'

class Post < Thor
  include FileUtils

  class_option :editor, default: "subl"
  class_option :open_editor, aliases: "-o", default: false, type: :boolean

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

    system(options[:editor], filename) if options[:open_editor]
  end

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

    # Create `_posts/` if not exists
    mkdir_p "_posts"

    f = File.open(original_file, 'r+')
    lines = f.readlines

    date_yaml = "date: #{options[:date]} #{options[:time]}"
    lines.insert(1, date_yaml)

    new_filename = "_posts/#{options[:date]}-#{File.basename(original_file)}"

    if File.exists?(new_filename)
      abort("#{filename} already exists!")
    end

    open(new_filename, 'w') do |post|
      lines.each { |line| post.puts line }
    end

    # Deletes old file
    File.delete(original_file)

    puts "Published draft to #{new_filename}"

    system(options[:editor], filename) if options[:open_editor]
  end
end
