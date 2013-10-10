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

# status for availability monitoring
get '/' do
    content_type 'application/json'
    {:status => 'running'}.to_json
end

# release route
get '/:user/:repo/:version' do

    if params[:format].nil?

        notes = get_notes(params[:user], params[:repo], params[:version])

        return 404 if notes.nil?

        markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
        rendered_notes = markdown.render(notes)

        haml :index, :locals => { :repo => params[:repo], :version => params[:version], :rendered_notes => rendered_notes }

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

get '/*' do
    404
end

__END__

@@ index
!!!
%html
    %head
        %title= "#{repo} #{version}"
    %body
        #{rendered_notes}
