#
#  releases.rb
#
#  Copyright (c) 2013 Marc Ransome <marc.ransome@fidgetbox.co.uk>
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to
#  deal in the Software without restriction, including without limitation the
#  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
#  sell copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
#  DEALINGS IN THE SOFTWARE.
#

require 'sinatra'
require 'haml'
require 'json'
require 'net/http'
require 'redcarpet'
require 'time'
require './lib/funcs'

configure :production do
  require 'newrelic_rpm'
end

APP_VERSION = "1.0.0"

# serve static site content for default route
get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

# expand pre-defined css template names to local paths
before do
  @css = params[:css]
  case @css
    when "sans" then @css = "/css/sans.css"
    when "serif" then @css = "/css/serif.css"
  end
end

# short-form route
get '/:user/:repo/?' do
  @title = params[:repo]
  @notes = get_notes({:user => params[:user], :repo => params[:repo]})
  return 404 if @notes.nil?
  haml :index, :ugly => params[:pretty].eql?("true") ? false : true
end

# long-form route for github compatibility
get '/:user/:repo/?:releases?/?:tag?/:tag_name/?' do
  @title = "#{params[:repo]} #{params[:tag_name]}"
  @notes = get_notes({:user => params[:user], :repo => params[:repo], :tag_name => params[:tag_name]})
  return 404 if @notes.nil?
  haml :index, :ugly => params[:pretty].eql?("true") ? false : true
end

# serve custom error page for 404s
not_found do
  send_file(File.join(settings.public_folder, '404.html'), {:status => 404})
end

__END__

@@ index
!!!
%html
  %head
    %meta{:charset => "utf-8"}
    %title= "#{@title}"
    - if not @css.nil?
      %link(rel="stylesheet" href="#{@css}")          
  %body
    - if params[:heading].eql?("true") 
      %h1 #{@title}
    #{@notes}
