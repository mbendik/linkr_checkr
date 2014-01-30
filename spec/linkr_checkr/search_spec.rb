require 'spec_helper'

describe LinkrCheckr::Search do
  let(:url)    { "http://abc.cz/dsds" }
  let(:search) { LinkrCheckr::Search.new(url) }

  before do
    stub_request(:any, url).to_return(body: "dsads")
  end

  describe "#search" do
    it "works :)" do
      expect{ search.call }.to_not raise_exception
    end

    context "with given not valid url" do
      before do
        search.uri = URI("kjdsakjdhsa")
      end

      it "raises argument error exception" do
        expect{ search.call }.to raise_exception
      end
    end

    it "saves cookie" do
      search.should_receive(:set_cookies).and_call_original
      search.call
    end

    it "checks documents" do
      search.should_receive(:check).and_call_original
      search.call
    end

    it "process errors" do
      search.should_receive(:process_errors).and_call_original
      search.call
    end

    describe "options" do
      let(:protocol) { "ftp" }
      let(:body)     { "<a href='#{protocol}://ljdlksad.cz/dsds'>" }

      before do
        stub_request(:any, url).to_return(body: body)
      end

      describe "prototcol" do
        context "given no protocol option" do
          it "marks protocol url as invalid" do
            search.call
            expect(search.error_links).to_not be_empty
          end
        end

        context "given protocol option" do
          let(:search) { LinkrCheckr::Search.new(url, {protocol: protocol}) }

          it "marks protocol url as invalid" do
            search.call
            expect(search.error_links).to be_empty
          end
        end
      end

      describe "send_mail" do
        let(:search2) { LinkrCheckr::Search.new(url, {send_mail: true}) }

        context "given send_mail option" do
          it "sends mail with errors" do
            LinkrCheckr::Mailer.should_receive(:new).and_call_original
            search2.call
          end
        end
      end
    end
  end

end

