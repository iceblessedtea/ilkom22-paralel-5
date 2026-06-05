require_relative "spec_helper"

RSpec.describe DoctorService::API do
  def app
    described_class
  end

  it "returns service health" do
    get "/health"

    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body)).to include(
      "status" => "ok",
      "service" => "doctor-service"
    )
  end

  it "lists doctors" do
    described_class::DB[:doctors].insert(
      name: "Dr. Dhany",
      specialization: "Pulmonolog",
      created_at: Time.now,
      updated_at: Time.now
    )

    get "/doctors"

    payload = JSON.parse(last_response.body)
    expect(last_response.status).to eq(200)
    expect(payload.first["name"]).to eq("Dr. Dhany")
  end
end
