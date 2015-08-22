###
# Blog settings
###

# Time.zone = "UTC"

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  # blog.prefix = "blog"

  blog.permalink = "{year}-{month}-{day}_{title}.html"
  # Matcher for blog source files
  blog.sources = "blog/{year}-{month}-{day}-{title}.html"
  # blog.taglink = "tags/{tag}.html"
  blog.layout = "blog"
  # blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  # blog.default_extension = ".markdown"

  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  # Enable pagination
  blog.paginate = true
  blog.per_page = 10
  blog.page_link = "page/{num}"
end

page "/feed.xml", layout: false

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
# page "/path/to/file.html", layout: false
#
# With alternative layout
# page "/path/to/file.html", layout: :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes


# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

set :tag_meta, {
  cucumber: {
      label: 'Cucumber',
      img: 'cucumber_logo.png',
      url: 'https://cukes.info'
  },
  phantomjs: {
      label: 'PhantomJS',
      img: 'phantomjs_logo.png',
      url: 'http://phantomjs.org/'
  },
  :"docker swarm" => {
      label: 'Docker Swarm',
      img: 'docker-swarm_logo.png',
      url: 'https://github.com/docker/swarm/'
  },
  ruby: {
      label: 'Ruby',
      img: 'ruby_logo.png',
      url: 'https://www.ruby-lang.org/en/'
  },
  github: {
      label: 'KeekDaGeek @ Github',
      img: 'github.png',
      url: 'https://github.com/keekdageek'
  },
  twitter: {
      label: 'KeekDaGeek @ Twitter',
      img: 'twitter.png',
      url: 'https://twitter.com/_keekdageek'
  },
  facebook: {
      label: 'KeekDaGeek @ Facebook',
      img: 'facebook.png',
      url: 'https://www.facebook.com/pages/KeekDaGeek/249840375103898'
  },
  linkedin: {
      label: 'KeekDaGeek @ LinkedIn',
      img: 'linkedin.png',
      url: 'https://www.linkedin.com/in/keekdageek'
  }
}


activate :google_analytics do |ga|
  # Property ID (default = nil)
  ga.tracking_id = 'UA-59522317-1'
  # Removing the last octet of the IP address (default = false)
  ga.anonymize_ip = false
  # Tracking across a domain and its subdomains (default = nil)
  ga.domain_name = 'keekdageek.com'
  # Tracking across multiple domains and subdomains (default = false)
  ga.allow_linker = false
  # Tracking Code Debugger (default = false)
  ga.debug = false
  # Tracking in development environment (default = true)
  ga.development = true
  # Compress the JavaScript code (default = false)
  ga.minify = false
end

activate :syntax
activate :meta_tags
activate :drafts
activate :directory_indexes

# sprockets.import_asset 'favicon.png'

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
  config[:file_watcher_ignore] += [
      /\.idea\/.*/,
      /.*\.iml/
  ]

  activate :disqus do |d|
    # using a special shortname
    d.shortname = "keekdageek"
    # or setting to `nil` will stop Disqus loading
    # d.shortname = nil
  end
end

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
  activate :favicon_maker do |f|
    f.icons = {
        "_favicon_template.png" => [
            { icon: "favicon.png", size: "16x16" },
            { icon: "favicon.ico", size: "64x64,32x32,24x24,16x16" },
        ]
    }
  end
  activate :disqus do |d|
    # using a different shortname for production builds
    d.shortname = "keekdageek"
  end
end


set :markdown, :fenced_code_blocks => true, :smartypants => true
set :haml, :format => :html5

