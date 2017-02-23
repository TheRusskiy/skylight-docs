require "skylight/docs/engine"

module Skylight
  module Docs
    class Chapter
      attr_accessor :description, :filename, :order, :title, :updated, :uri
      @@chapters = []

      # absolute path to the /markdown folder
      FOLDER = File.expand_path('../../../source', __FILE__)

      # Creates an object containing content and metadata about a docs chapter.
      # Takes a filename (such as 'running-skylight') on initialization.
      #
      # The attributes on the object on initialization will be as follows:
      # { 'title' => 'title',
      #   'description' => 'description',
      #   'order' => #,
      #   'updated' => 'date last updated',
      #   'filename' => 'dashified-file-name',
      #   'uri' => '/support/dashified-file-name',
      #   'file' => 'The full contents of the file',
      #   'content' => nil }
      #
      # `content` is set lazily the first time it's used
      def initialize(filename)
        path = File.join(FOLDER, "#{filename}.md")

        raise "File Not Found: #{filename}" unless File.exist?(path)
        raise "File Not Found in #{FOLDER}: #{filename}" unless File.dirname(path) == FOLDER

        @filename = filename
        @file = File.read(path)

        @uri = "/support/#{filename}"

        @content = nil

        set_frontmatter
      end

      # Sets and returns a class variable @@chapters, which is an array of
      # Chapter objects derived from the markdown folders in /source.
      # These chapters are sorted by their `order` attribute.
      def self.all
        # Match .md files in /source but not in /source/deprecated
        pattern = File.join(FOLDER, "*.md")

        @@chapters = Dir[pattern].map do |path|
          Skylight::Docs::Chapter.new(File.basename(path, '.md'))
        end

        @@chapters.sort_by { |chapter| chapter.order }
      end

      # Given a filename, such as 'running-skylight', returns a particular
      # Chapter object from the @@chapters array.
      def self.find(filename_to_find)
        @@chapters.find { |chapter| chapter.filename == filename_to_find }
      end

      # Returns the `content` of a Chapter object. If `content` has not been
      # set, it sets the content to the parsed markdown of that Chapter's file
      # minus its frontmatter.
      def content
        # use Kramdown to parse a GitHub-flavored markdown (GFM) file to HTML
        @content ||= Kramdown::Document.new(clean_markdown, :input => 'GFM').to_html
      end

      private

        # Sets the frontmatter attributes on the Chapter object and validates
        # that all required frontmatter has been added
        def set_frontmatter
          valid_keys = ["title", "description", "order", "updated"]
          frontmatter = YAML.load(@file)

          valid_keys.each do |key|
            value = frontmatter[key]
            raise "Set frontmatter for `#{key}`" unless value
            instance_variable_set("@" + key, value)
          end
        end

        # Gets the content of a file at a specified path with any frontmatter removed
        def clean_markdown
          frontmatter = get_frontmatter
          # if there is frontmatter, return everything but the frontmatter
          frontmatter ? frontmatter.post_match : @file
        end

        # Gets a MatchData object representing the frontmatter from the file at the specified path
        def get_frontmatter
          # found this Regex in the Jekyll repo, used to parse frontmatter
          # https://github.com/jekyll/jekyll/blob/27ed81547b12d28a60c51961b82a5723981feb7d/lib/jekyll/document.rb#L10
          frontmatter_regex = %r!\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)!m
          @file.match(frontmatter_regex)
        end
    end
  end
end
