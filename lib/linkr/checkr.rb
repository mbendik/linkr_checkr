require 'linkr/checkr/version'
require 'nokogiri'
require 'net/http'
require 'net/https'
require 'uri'

module Linkr
  class Checkr

    attr_accessor :uri
    attr_accessor :cookies
    attr_accessor :options
    attr_accessor :links
    attr_accessor :error_links
    attr_accessor :cookies

    def initialize(url, options = {})
      @uri         = URI(url)
      @options     = options
      @links       = []
      @error_links = []
    end

    def search
      raise ArgumentError unless valid_url?(@uri.to_s)

      http         = Net::HTTP.new(@uri.host)
      http.use_ssl = true if @uri.scheme == "https"
      response     = http.get(@uri)

      if response.is_a?(Net::HTTPSuccess)
        set_cookies(response)
        document = Nokogiri::HTML(response.body)

        check([document])
        process_errors
      end
    end

    private

    def check(documents)
      new_documents = []

      documents.each do |document|
        a_links   = get_links(document.css('a'))
        js_links  = get_links(document.css('script'), "src")
        css_links = get_links(document.css('link'))
        links     = a_links + js_links + css_links

        links.each do |link|
          next if @links.include?(link)
          new_documents << request_link(link)
        end
      end

      new_documents.compact!
      check(new_documents) if new_documents.present?
    end

    def request_link(link)
      document        = nil
      link_uri        = URI.parse(link)
      link_uri.host   = @uri.host   unless link_uri.host
      link_uri.scheme = @uri.scheme unless link_uri.scheme

      if valid_url?(link_uri.to_s)
        http         = Net::HTTP.new(link_uri.host)
        http.use_ssl = true if link_uri.scheme == "https"

        path = link_uri.path
        path = path + "?#{link_uri.query}" if link_uri.query
        http.request_get(path, {'Cookie' => @cookies}) do |response|
          set_cookies(response)
          @links << link
          case response
          when Net::HTTPSuccess  then
            document = add_document(link_uri, response)
          when Net::HTTPFound    then
            p "redirect:"
            p response["location"]
            document = request_link(response["location"])
          when Net::HTTPNotFound then @error_links << link_uri.to_s
          end
        end
      else
        @error_links << link_uri.to_s unless valid_protocol?(link_uri.to_s)
      end
      document
    end

    def get_links(elements, attr = "href")
      elements.map do |el|
        el.attributes[attr].try(:value)
      end.compact
    end

    def valid_url?(url)
      url.match(URI.regexp(/(http|https)/)).present?
    end

    def valid_protocol?(url)
      protocols = %w(http https)
      if protocol = @options[:protocol]
        protocols << protocol if protocol.is_a?(String)
      end
      url.match(URI.regexp(/(#{protocols.join('|')})/)).present?
    end

    def add_document(uri, response)
      unless uri.path.match(/(\.(css|js))/).present?
        Nokogiri::HTML(response.body)
      end
    end

    def set_cookies(response)
      cookies = response.get_fields('set-cookie')
      @cookies = cookies.first if cookies.present?
    end

    def process_errors
      p "Links with error:"
      @error_links.uniq.each{|l| p l}
    end
  end
end

ch=Linkr::Checkr.new("http://integration.cashplay.co/mobile/home?game_id=1&lat=50&lng=14").search
ch=Linkr::Checkr.new("https://app.cashplay.co/mobile/home?game_id=1&lat=50&lng=14").search


ch=Linkr::Checkr.new("http://cashplay.dev/mobile/home?game_id=1&lat=50&lng=14").search
