#
#  funcs.rb
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

def get_notes(options = {})
  uri = URI("https://api.github.com/repos/#{options[:user]}/#{options[:repo]}/releases")
  
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  
  request = Net::HTTP::Get.new(uri)
  request.add_field 'Accept', 'application/vnd.github.manifold-preview'
  request.add_field 'Authorization', "token #{ENV['GITHUB_AUTH_TOKEN']}"
  request.add_field 'User-Agent', "releases-io/#{APP_VERSION}"
  
  response = http.request(request)
  
  return nil if not response.kind_of? Net::HTTPSuccess
  
  json = JSON.parse(response.body)
  
  notes = nil
  
  if options[:tag_name].nil?
    notes = extract_latest(json)
  else
    notes = extract_tag(json, options[:tag_name])
  end
  
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :fenced_code_blocks => true)
  notes.nil? ? nil : markdown.render(notes)
end

def extract_latest(json)
  latest_release = []
  comparator = Time.utc(1970, "jan", 1)

  json.each do |release|
    release_date = Time.parse(release["published_at"])
    if release_date > comparator
      comparator = release_date
      latest_release = release
      next
    end
  end
  latest_release["body"]
end

def extract_tag(json, tag_name)
  json.each do |release|
    if release["tag_name"].eql?(tag_name)
      return release["body"]
    end
  end
  nil
end
