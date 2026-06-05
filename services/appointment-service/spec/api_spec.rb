require_relative "spec_helper"

RSpec.describe AppointmentService::API do
  def app
    described_class
  end

  describe ".http_get" do
    it "normalizes a Net::HTTP response" do
      response = instance_double(Net::HTTPResponse, code: "200", body: '{"ok":true}')
      allow(Net::HTTP).to receive(:get_response).and_return(response)

      result = described_class.http_get("http://example.test/health")

      expect(result.status).to eq(200)
      expect(result.body).to eq('{"ok":true}')
    end
  end

  it "returns service health" do
    get "/health"

    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body)).to include(
      "status" => "ok",
      "service" => "appointment-service"
    )
  end

  it "returns an empty collection when no appointments exist" do
    get "/appointments"

    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body)).to eq([])
  end
end
