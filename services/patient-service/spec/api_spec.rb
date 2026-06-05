require_relative "spec_helper"

RSpec.describe PatientService::API do
  def app
    described_class
  end

  it "returns service health" do
    get "/health"

    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body)).to include(
      "status" => "ok",
      "service" => "patient-service"
    )
  end

  it "lists patients" do
    described_class::DB[:patients].insert(
      name: "Andi Wijaya",
      age: 30,
      gender: "Laki-laki",
      address: "Kendari",
      created_at: Time.now,
      updated_at: Time.now
    )

    get "/patients"

    payload = JSON.parse(last_response.body)
    expect(last_response.status).to eq(200)
    expect(payload["success"]).to eq(true)
    expect(payload["patients"].first["name"]).to eq("Andi Wijaya")
  end
end
