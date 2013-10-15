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

require './lib/funcs'

APP_VERSION = "0.1.0"

configure :production do
    require 'newrelic_rpm'
end

# serve static site content for default route
get '/' do
    send_file File.join(settings.public_folder, 'index.html')
end

# release route
get '/:user/:repo/?:releases?/:version' do

    # default (html) response
    if params[:format].nil?
        notes = get_notes(params[:user], params[:repo], params[:version])
        return 404 if notes.nil?

        markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :fenced_code_blocks => true)
        rendered_notes = markdown.render(notes)

        haml :index, :locals => { :repo => params[:repo], :version => params[:version], :rendered_notes => rendered_notes }

    # markdown response
    elsif params[:format].eql? "markdown"
        content_type :text, 'charset' => 'utf-8'
        notes = get_notes(params[:user], params[:repo], params[:version])

        if notes.nil?
            return 404
        else
            return notes
        end
    end
end

# catch-all for non-matching routes
get '/*' do
    404
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
        %title= "#{repo} #{version}"
        - if params[:css] 
            %link(rel="stylesheet" href="#{params[:css]}")          
    %body
        #{rendered_notes}
