require "rails_helper"

RSpec.describe Import::FromCSV, "#call" do
  let(:service) { Import::FromCSV.new(path) }
  let(:path) { File.expand_path(File.dirname(__FILE__) + "/../../../sample-daily-stats.csv") }

  context 'when there is already a record for that date' do
    let!(:capacity) {
      Capacity.create({
        date: Date.parse('2016-09-06'),
        funded: 1001,
        reserve: 101,
        activated: 202,
        unavailable: 333,
        status: 'locked'
      })
    }

    it 'updates the values that do not exist yet' do
      service.call
      capacity.reload
      expect(capacity.in_care).to eq(4571)
      expect(capacity.referrals).to eq(8)
      expect(capacity.discharges).to eq(6)
    end

    it 'will overwrite those value' do
      service.call
      capacity.reload
      expect(capacity.funded).to eq(6000)
      expect(capacity.reserve).to eq(2200)
      expect(capacity.activated).to eq(600)
      expect(capacity.unavailable).to eq(56)
    end
  end

  context 'when there is not a record for that date' do
    let(:capacity) { Capacity.where(reported_on: Date.parse('2016-09-06')).first }

    it 'imports creates records' do
      service.call
      expect(Capacity.count).to eq(49)
    end

    it 'record has the right imported values' do
      service.call
      expect(capacity.in_care).to eq(4571)
      expect(capacity.referrals).to eq(8)
      expect(capacity.discharges).to eq(6)
      expect(capacity.funded).to eq(6000)
      expect(capacity.reserve).to eq(2200)
      expect(capacity.activated).to eq(600)
      expect(capacity.unavailable).to eq(56)
    end
  end
end
