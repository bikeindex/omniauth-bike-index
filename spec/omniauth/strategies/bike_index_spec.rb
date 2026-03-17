require "spec_helper"

describe OmniAuth::Strategies::BikeIndex do
  let(:app) { lambda { |env| [200, {}, ["Hello World."]] } }
  let(:options) { {} }

  subject do
    OmniAuth::Strategies::BikeIndex.new(app, "client_id", "client_secret", options).tap do |strategy|
      allow(strategy).to receive(:request).and_return(request)
      allow(strategy).to receive(:session).and_return(session)
    end
  end

  let(:request) { double("Request", params: {}, scheme: "https", url: "https://example.com/callback") }
  let(:session) { {} }

  context "client options" do
    it "has correct name" do
      expect(subject.options.name).to eq(:bike_index)
    end

    it "has correct site" do
      expect(subject.options.client_options.site).to eq("https://bikeindex.org")
    end

    it "has correct authorize url" do
      expect(subject.options.client_options.authorize_url).to eq("/oauth/authorize")
    end
  end

  context "raw_info" do
    let(:parsed_response) do
      {
        "id" => 42,
        "user" => {"username" => "bike_rider", "email" => "rider@example.com", "name" => "Bike Rider",
                   "secondary_emails" => ["alt@example.com"], "twitter" => "bikerider", "image" => "https://example.com/photo.jpg"},
        "bike_ids" => [1, 2, 3]
      }
    end
    let(:access_token) { double("AccessToken") }
    let(:response) { double("Response", parsed: parsed_response) }

    before do
      allow(subject).to receive(:access_token).and_return(access_token)
      allow(access_token).to receive(:get).with("/api/v3/me").and_return(response)
    end

    it "fetches from /api/v3/me" do
      expect(subject.raw_info).to eq(parsed_response)
    end

    it "memoizes the result" do
      subject.raw_info
      subject.raw_info
      expect(access_token).to have_received(:get).once
    end

    context "when parsed response is nil" do
      let(:response) { double("Response", parsed: nil) }

      it "returns empty hash" do
        expect(subject.raw_info).to eq({})
      end
    end
  end

  context "uid" do
    let(:access_token) { double("AccessToken") }
    let(:response) { double("Response", parsed: {"id" => 42, "user" => {}, "bike_ids" => []}) }

    before do
      allow(subject).to receive(:access_token).and_return(access_token)
      allow(access_token).to receive(:get).with("/api/v3/me").and_return(response)
    end

    it "returns the user id" do
      expect(subject.uid).to eq(42)
    end
  end

  context "info" do
    let(:access_token) { double("AccessToken") }
    let(:parsed_response) do
      {
        "id" => 42,
        "user" => {"username" => "bike_rider", "email" => "rider@example.com", "name" => "Bike Rider",
                   "secondary_emails" => ["alt@example.com"], "twitter" => "bikerider", "image" => "https://example.com/photo.jpg"},
        "bike_ids" => [1, 2, 3]
      }
    end
    let(:response) { double("Response", parsed: parsed_response) }

    before do
      allow(subject).to receive(:access_token).and_return(access_token)
      allow(access_token).to receive(:get).with("/api/v3/me").and_return(response)
    end

    it "returns mapped user info" do
      expect(subject.info).to eq(
        "nickname" => "bike_rider",
        "bike_ids" => [1, 2, 3],
        "email" => "rider@example.com",
        "secondary_emails" => ["alt@example.com"],
        "name" => "Bike Rider",
        "twitter" => "bikerider",
        "image" => "https://example.com/photo.jpg"
      )
    end

    context "with nil and empty values" do
      let(:parsed_response) do
        {
          "id" => 42,
          "user" => {"username" => "bike_rider", "email" => "rider@example.com", "name" => nil,
                     "secondary_emails" => [], "twitter" => "", "image" => nil},
          "bike_ids" => [1]
        }
      end

      it "prunes nil and empty values" do
        expect(subject.info).to eq(
          "nickname" => "bike_rider",
          "bike_ids" => [1],
          "email" => "rider@example.com"
        )
      end
    end
  end

  context "extra" do
    let(:access_token) { double("AccessToken") }
    let(:parsed_response) { {"id" => 42, "user" => {"username" => "bike_rider"}, "bike_ids" => []} }
    let(:response) { double("Response", parsed: parsed_response) }

    before do
      allow(subject).to receive(:access_token).and_return(access_token)
      allow(access_token).to receive(:get).with("/api/v3/me").and_return(response)
    end

    it "includes raw_info" do
      expect(subject.extra["raw_info"]).to eq(parsed_response)
    end

    context "when skip_info is true" do
      let(:options) { {skip_info: true} }

      it "returns empty hash" do
        expect(subject.extra).to eq({})
      end
    end
  end

  context "param_or_option" do
    context "with omniauth params in session" do
      let(:session) { {"omniauth.params" => {"partner" => "from_param"}} }

      it "returns session param" do
        expect(subject.param_or_option("partner")).to eq("from_param")
      end
    end

    context "with option configured" do
      let(:options) { {"partner" => "from_option"} }

      it "returns option value" do
        expect(subject.param_or_option("partner")).to eq("from_option")
      end
    end

    context "with both param and option" do
      let(:session) { {"omniauth.params" => {"partner" => "from_param"}} }
      let(:options) { {"partner" => "from_option"} }

      it "prefers the session param" do
        expect(subject.param_or_option("partner")).to eq("from_param")
      end
    end

    context "with neither" do
      it "returns nil" do
        expect(subject.param_or_option("partner")).to be_nil
      end
    end
  end

  context "request_phase" do
    before do
      allow(subject).to receive(:redirect)
      allow(subject).to receive(:callback_url).and_return("https://example.com/callback")
    end

    it "sets default scope" do
      subject.request_phase
      expect(subject.options[:authorize_params][:scope]).to eq("public")
    end

    context "with custom scope" do
      let(:options) { {"scope" => "read_bikes"} }

      it "uses the custom scope" do
        subject.request_phase
        expect(subject.options[:authorize_params][:scope]).to eq("read_bikes")
      end
    end

    context "with partner in session params" do
      let(:session) { {"omniauth.params" => {"partner" => "Metro", "company" => "ACME"}} }

      it "passes partner and company to authorize_params" do
        subject.request_phase
        expect(subject.options[:authorize_params][:partner]).to eq("Metro")
        expect(subject.options[:authorize_params][:company]).to eq("ACME")
      end
    end

    context "with unauthenticated_redirect" do
      let(:session) { {"omniauth.params" => {"unauthenticated_redirect" => "https://example.com/login"}} }

      it "passes unauthenticated_redirect to authorize_params" do
        subject.request_phase
        expect(subject.options[:authorize_params][:unauthenticated_redirect]).to eq("https://example.com/login")
      end
    end
  end

  context "callback_url" do
    before do
      allow(subject).to receive(:full_host).and_return("https://example.com")
      allow(subject).to receive(:script_name).and_return("")
      allow(subject).to receive(:callback_path).and_return("/auth/bike_index/callback")
    end

    it "constructs url from full_host, script_name, and callback_path" do
      expect(subject.callback_url).to eq("https://example.com/auth/bike_index/callback")
    end

    context "with script_name" do
      before { allow(subject).to receive(:script_name).and_return("/app") }

      it "includes script_name" do
        expect(subject.callback_url).to eq("https://example.com/app/auth/bike_index/callback")
      end
    end
  end

  context "prune!" do
    let(:access_token) { double("AccessToken") }

    before do
      allow(subject).to receive(:access_token).and_return(access_token)
    end

    it "removes nil values" do
      result = subject.send(:prune!, {"a" => 1, "b" => nil})
      expect(result).to eq({"a" => 1})
    end

    it "removes empty strings" do
      result = subject.send(:prune!, {"a" => 1, "b" => ""})
      expect(result).to eq({"a" => 1})
    end

    it "removes empty arrays" do
      result = subject.send(:prune!, {"a" => 1, "b" => []})
      expect(result).to eq({"a" => 1})
    end

    it "removes empty nested hashes" do
      result = subject.send(:prune!, {"a" => 1, "b" => {"c" => nil}})
      expect(result).to eq({"a" => 1})
    end

    it "keeps nested hashes with values" do
      result = subject.send(:prune!, {"a" => 1, "b" => {"c" => 2}})
      expect(result).to eq({"a" => 1, "b" => {"c" => 2}})
    end
  end
end
