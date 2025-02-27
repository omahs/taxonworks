require 'rails_helper'

describe InternalAttribute, type: :model do
  let(:internal_attribute) { InternalAttribute.new }
  let(:otu) { FactoryBot.build(:valid_otu) }
  let(:predicate) { FactoryBot.create(:valid_controlled_vocabulary_term_predicate) }

  specify '.batch_create 1' do
    o1 = FactoryBot.create(:valid_otu)
    o2 = FactoryBot.create(:valid_otu)

    p = FactoryBot.create(:valid_predicate)

    h = {
      attribute_subject_id: [o1.id, o2.id],
      attribute_subject_type: 'Otu',
      controlled_vocabulary_term_id: p.id,
      value: 22
    }

    p = ActionController::Parameters.new(h)
    p.permit!
   
    InternalAttribute.batch_create(p)
    
    expect(InternalAttribute.count).to eq(2)
    expect(InternalAttribute.first.value).to eq('22')
  end

  context 'validation' do
    before(:each) {
      internal_attribute.valid?
    }
    context 'requires' do
      specify 'predicate' do
        expect(internal_attribute.errors.include?(:predicate)).to be_truthy
      end
    end

    context 'uniqueness' do
      let!(:da1) { InternalAttribute.create!(predicate: predicate, value: '1234', attribute_subject: otu) }

      specify 'same predicate, same value, is not allowed' do
        expect( InternalAttribute.new(predicate: predicate, value: '1234', attribute_subject: otu).valid?).to be_falsey
      end

      specify 'same predicate, different values are allowed' do
        expect( InternalAttribute.create!(predicate: predicate, value: '4567', attribute_subject: otu)).to be_truthy
      end

      specify 'different predicate, same value are allowed' do
        expect( InternalAttribute.create!(predicate: FactoryBot.create(:valid_predicate), value: '1234', attribute_subject: otu)).to be_truthy
      end
    end
  end

  specify 'a valid record can be created' do
    expect(InternalAttribute.create(predicate: predicate, value: '1234', attribute_subject: otu)).to be_truthy
  end

  specify 'non-persisted data attribute with non-persisted predicate' do
    internal_attribute.value = '1234'
    otu
    internal_attribute.attribute_subject = otu
    new_predicate = FactoryBot.build(:valid_predicate)
    internal_attribute.predicate = new_predicate

    [new_predicate, internal_attribute].each {|o| o.save!}
  end

  specify '#predicate returns' do
    i =  InternalAttribute.create(predicate: predicate, value: '1234', attribute_subject: otu)
    expect(i.predicate).to eq(predicate)
    i.reload
    expect(i.predicate).to eq(predicate)
  end

  specify 'a valid record can be created with reference to superclass' do
    i = DataAttribute.create(
      controlled_vocabulary_term_id:  predicate.id,
      type: 'InternalAttribute',
      value: '1234', attribute_subject: otu)
    expect(i.valid?).to be(true)

  end

  specify 'a valid record can be created with reference to superclass' do
    i = DataAttribute.create!(
               controlled_vocabulary_term_id:  predicate.id,
                type: 'InternalAttribute',
               value: '1234', attribute_subject: otu
    )
    expect(i.valid?).to be(true)

    o = DataAttribute.find(i.id)
    expect(o.predicate).to eq(i.predicate)
    expect(o.predicate).to eq(predicate)
  end
end

