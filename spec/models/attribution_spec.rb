require 'rails_helper'

RSpec.describe Attribution, type: :model do

  let(:attribution) { Attribution.new }

  specify '#license' do 
    attribution.license = 'foo'
    attribution.valid?
    expect(attribution.errors.include?(:license)).to be_truthy
  end

  specify '#copyright_year 1' do 
    attribution.copyright_year = '1'
    attribution.valid?
    expect(attribution.errors.include?(:copyright_year)).to be_truthy
  end

  specify '#copyright_year 2' do 
    attribution.copyright_year = '1984'
    attribution.valid?
    expect(attribution.errors.include?(:copyright_year)).to be_falsey
  end

  specify '#attribution_object_type' do
    attribution.attribution_object_type = "" 
    attribution.save
    expect(attribution.attribution_object_type).to eq(nil) 
  end

end
