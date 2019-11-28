require "open-uri"

class ReadUrl
  def initialize(redirect_forbidden_url, on_redirect, on_redirect_to__forbidden_url, on_error)
    @redirect_forbidden_url = redirect_forbidden_url
    @on_redirect = on_redirect
    @on_redirect_to__forbidden_url = on_redirect_to__forbidden_url
    @on_error = on_error
  end

  private def read_url(url, &block)
    url = UrlUtil.to_absolute_url(url)
    $stdout.print "GET: #{url}\n"
    begin
      result = nil
      OpenURI.open_uri(url, redirect: false) { |io|
        result = block[io, url]
      }
      return result
    rescue OpenURI::HTTPRedirect => e
      redirected_url = e.uri.to_s
      @on_redirect[e, url, redirected_url]
      if @redirect_forbidden_url == redirected_url
        return @on_redirect_to__forbidden_url[e, url]
      else
        return read_url(redirected_url, &block)
      end
    rescue OpenURI::HTTPError => e
      return @on_error[e, url]
    end
  end

  def read_html(url, &block)
    read_url(url) { |io, url|
      block[io, url] if block
      Nokogiri::HTML.parse(io, url)
    }
  end

  def read_xml(url, &block)
    if url.end_with? ".gz"
      read_url(url) { |io, url|
        block[io, url] if block
        Nokogiri::XML.parse(Zlib::GzipReader.new(io), url)
      }
    else
      read_url(url) { |io, url|
        block[io, url] if block
        Nokogiri::XML.parse(io, url)
      }
    end
  end
end
