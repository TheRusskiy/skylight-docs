###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
# activate :livereload

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

Dir[File.expand_path('../lib/*.rb', __FILE__)].each { |f| require f }

set :source,     'src'
set :css_dir,    'css'
set :js_dir,     'js'
set :images_dir, 'img'

activate :directory_indexes
activate :syntax
activate :quickjump
activate :livereload

#set :markdown_engine, :kramdown
set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

helpers Helpers

# Build-specific configuration
configure :build do
  # Checks relative links
  activate :link_check

  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Enable cache buster
  activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_path, "/Content/images/"
end
