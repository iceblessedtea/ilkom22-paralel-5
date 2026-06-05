require_relative "spec_helper"

RSpec.describe MedicalRecordService::API do
  def app
    described_class
  end

  it "returns service health" do
    get "/health"

    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body)).to include(
      "status" => "ok",
      "service" => "medical-record-service"
    )
  end

  it "lists medical records" do
    allow_any_instance_of(described_class).to receive(:fetch_patient).and_return({ "name" => "Andi Wijaya" })
    described_class::DB[:medical_records].insert(
      patient_id: 1,
      diagnosis: "Flu",
      created_at: Time.now,
      updated_at: Time.now
    )

    get "/medical-records"

    payload = JSON.parse(last_response.body)
    expect(last_response.status).to eq(200)
    expect(payload.first["patient_name"]).to eq("Andi Wijaya")
    expect(payload.first["diagnosis"]).to eq("Flu")
  end
end
