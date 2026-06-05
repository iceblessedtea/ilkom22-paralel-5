require_relative "spec_helper"

RSpec.describe AppointmentService::API do
  def app
    described_class
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
