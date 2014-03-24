require 'rubygems'
require 'bundler'
Bundler.require

require './main'

use Rack::ETag

# Rewrite content types based on file extensions
class RewriteContentType
  def initialize app, opts
    @app = app
    @map = opts
  end
  def call env
    res = @app.call(env)
    ext = env["PATH_INFO"].split(".")[-1]
    res[1]["Content-Type"] = @map[ext] if @map.has_key?(ext)
    res
  end
end

use RewriteContentType, {"js" => "text/javascript", "htc" => "text/x-component", "manifest" => "application/manifest"}

map "/application.manifest" do
  offline = Rack::Offline.new :cache => false, :root => "public", :cache_interval => 20 do
    # Cache all files under the directory public
    Dir[File.join(settings.public_folder, "**/*.*")].each do |file|
      cache file.sub(File.join(settings.public_folder, ""), "")
    end

    Dir[File.join("#{ROOT_DIR}/app/views/css/", "*.sass")].each do |file|
      tmp = file.split('/').last
      tmp = tmp.split('.')
      tmp.pop
      tmp = tmp.join(".")
      tmp << ".css"
      tmp = "css/" << tmp
      cache tmp
    end

    # All other files should be downloaded
    network '/'
  end
  run offline
end

map '/' do
  run MyScrum::Main
end

map '/admin' do
  run MyScrum::AdminApp
end

map '/owner' do
  run MyScrum::OwnerApp
end

map '/api' do
  run MyScrum::ApiApp
end

