require 'mail'

module LinkrCheckr
  class Mailer

    attr_accessor :error_links

    def initialize(error_links)
      @error_links = error_links
    end

    def deliver
      body = "Dead links: \n \n"
      body << @error_links.join("\n")
      Mail.deliver do
        from    'linkr-checker@test.com'
        to      'test@test.com'
        subject 'Link error report'
        body    body
      end
    end
  end
end

Mail.defaults do
  delivery_method :smtp, address: "localhost", port: 1025
end
