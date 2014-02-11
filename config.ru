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

map '/' do
  run MyScrum::Main
end

map '/admin' do
  run MyScrum::AdminApp
end

map '/user' do
  run MyScrum::UserApp
end

map '/signup' do
  run MyScrum::RegisterApp
end

