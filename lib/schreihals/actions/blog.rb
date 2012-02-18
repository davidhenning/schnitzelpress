module Schreihals
  module Actions
    module Blog
      extend ActiveSupport::Concern

      included do
        get '/' do
          # cache_for 5.minutes
          @posts = Post.latest
          @show_description = true
          haml :index
        end

        get '/blog.css' do
          cache_for 1.hour
          scss :blog
        end

        get '/index.atom' do
          cache_for 3.minutes
          @posts = Post.latest.limit(10)
          content_type 'application/atom+xml; charset=utf-8'
          haml :atom, :format => :xhtml, :layout => false
        end

        get '/feed/?' do
          redirect settings.feed_url
        end

        get '/:year/:month/:day/:slug/?' do |year, month, day, slug|
          # cache_for 1.hour
          render_page(slug)
        end

        get '/:slug/?' do |slug|
          # cache_for 1.hour
          render_page(slug)
        end
      end
    end
  end
end
