require 'spec_helper'

describe LogDispatch do
  let(:log) do
    FactoryBot.create(:log, channels: ["email"])
  end

  it "has a default wait time for batching" do
    wt = LogDispatch.digest_wait_time
    expect(wt).to be_kind_of(Hash)
    expect(wt[:wait]).to eq(30.seconds)
  end

  it "sends routine emails" do
    original_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test

    expect {
      LogDispatch.send_routine_emails(log, log.device)
    }.to have_enqueued_job(ActionMailer::DeliveryJob)
  ensure
    ActiveJob::Base.queue_adapter = original_adapter
  end
end
