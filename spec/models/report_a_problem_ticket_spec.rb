# encoding: UTF-8

require 'rails_helper'

RSpec.describe ReportAProblemTicket, type: :model do
  def ticket(params = {})
    ReportAProblemTicket.new(params)
  end

  it "should validate the presence of 'what_wrong'" do
    expect(ticket(what_wrong: '').errors[:what_wrong].size).to eq(1)
  end

  it "should validate the presence of 'what_doing'" do
    expect(ticket(what_doing: '').errors[:what_doing].size).to eq(1)
  end

  it "should filter 'javascript_enabled'" do
    expect(ticket(javascript_enabled: 'true').javascript_enabled).to be_truthy

    expect(ticket(javascript_enabled: 'false').javascript_enabled).to be_falsey
    expect(ticket(javascript_enabled: 'xxx').javascript_enabled).to be_falsey
    expect(ticket(javascript_enabled: '').javascript_enabled).to be_falsey
  end

  it "should filter 'page_owner'" do
    expect(ticket(page_owner: 'abc').page_owner).to eq('abc')
    expect(ticket(page_owner: 'number_10').page_owner).to eq('number_10')

    expect(ticket(page_owner: nil).page_owner).to be_nil
    expect(ticket(page_owner: '').page_owner).to be_nil
    expect(ticket(page_owner: 'spaces not allowed').page_owner).to be_nil
    expect(ticket(page_owner: '<hax>').page_owner).to be_nil
    expect(ticket(page_owner: 'S&P').page_owner).to be_nil
  end

  it "should filter 'source'" do
    expect(ticket(source: 'mainstream').source).to eq('mainstream')
    expect(ticket(source: 'page_not_found').source).to eq('page_not_found')
    expect(ticket(source: 'inside_government').source).to eq('inside_government')

    expect(ticket(source: 'xxx').source).to be_nil
  end

  context "spam detection" do
    it "should mark single word submissions as spam" do
      expect(ticket(what_doing: 'oneword', what_wrong: '')).to be_spam
      expect(ticket(what_doing: '', what_wrong: 'oneword')).to be_spam
      expect(ticket(what_doing: 'oneword', what_wrong: 'oneword')).to be_spam
    end

    it 'should mark Web Cruiser scanning as spam' do
      expect(ticket(what_doing: 'WCRTESTINP scanning')).to be_spam
      expect(ticket(what_wrong: 'WCRTESTINP scanning')).to be_spam
    end

    it 'should allow genuine submissions' do
      expect(ticket(what_doing: 'browsing', what_wrong: 'it broke')).to_not be_spam
    end
  end
end
