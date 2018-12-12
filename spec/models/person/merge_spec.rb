require 'rails_helper'

describe Person, type: :model do

  let(:root_taxon_name) { Protonym.create!(name: 'Root', rank_class: 'NomenclaturalRank', parent_id: nil) }
  let(:tn1) { Protonym.create!(name: 'Aonedidae', parent: root_taxon_name, rank_class: Ranks.lookup(:iczn, :family)) }
  let(:tn2) { Protonym.create!(name: 'Atwodidae', parent: root_taxon_name, rank_class: Ranks.lookup(:iczn, :family)) }

  let!(:person1) do 
    FactoryBot.create(
      :person,
      first_name: 'January', last_name: 'Smith',
      prefix: 'Dr.', suffix: 'III')
  end 

  let(:gr2) { FactoryBot.create(:valid_georeference) }

  let(:da1) { FactoryBot.create(
    :valid_data_attribute_internal_attribute,
    value: 'Dr.',
    predicate: cvt) }

  let(:cvt) { FactoryBot.create(
    :valid_controlled_vocabulary_term_predicate,
    name: ' Honorific',
    definition: 'People:Honorific imported from INHS FileMaker database.') }

  let!(:person1b) do 
    FactoryBot.create(
      :person,
      first_name: 'January', last_name: 'Smith',
      prefix: 'Dr.', suffix: 'III',
      year_born: 2000, year_died: 2015,
      year_active_start: 2012, year_active_end: 2015)
  end 

  let(:person1c) do 
     FactoryBot.create(
      :person,
      first_name: 'January', last_name: 'Smith',
      prefix: 'Dr.', suffix: 'III',
      year_born: 2000, year_died: 2015,
      year_active_start: 2012, year_active_end: 2015)
  end 

  let(:av1) { FactoryBot.create(:valid_alternate_value,
                                value:                            'Jan',
                                alternate_value_object_attribute: 'first_name',
                                alternate_value_object:           person1b) }
  let(:av2) { FactoryBot.create(:valid_alternate_value,
                                value:                            'Janco',
                                alternate_value_object_attribute: 'first_name',
                                alternate_value_object:           person1) }

  let(:id1) { FactoryBot.create(:valid_identifier) }

  let(:no1) { FactoryBot.create(:valid_note) }
  let(:da2) { FactoryBot.create(:valid_data_attribute_internal_attribute,
                                value:     'Mr.',
                                predicate: cvt) }


  let(:gr1) { FactoryBot.create(:valid_georeference) }

  context 'roles' do
    before do 
      gr2.georeferencers << person1

      tn1.taxon_name_authors << person1b 
      tn2.taxon_name_authors << person1b 
      gr1.georeferencers << person1b 
    end

    specify 'exist' do
      expect(Role.count).to eq(4)
    end

    specify 'are combined' do
      person1.merge_with(person1b.id)
      expect(person1.roles.map(&:type)).to contain_exactly('TaxonNameAuthor', 'Georeferencer', 'Georeferencer', 'TaxonNameAuthor')
    end

    specify 'are not destroyed' do
      person1.merge_with(person1b.id)
      expect(Role.count).to eq(4)
    end
  end

  context 'roles 2' do
    let!(:p1) { Person.create!(last_name: 'Smith') }
    let!(:p2) { Person.create!(last_name: 'Jones') }

    let!(:s1) { FactoryBot.create(:valid_source) }
    let!(:s2) { FactoryBot.create(:valid_source) }

    let!(:r1) { SourceAuthor.create!(person: p1, role_object: s1) }
    let!(:r2) { SourceAuthor.create!(person: p2, role_object: s2) }

    specify 'merge 1' do
      p1.merge_with(p2.id)
      expect(Role.count).to eq(2)
    end

    specify 'merge 2' do
      p1.merge_with(p2.id)
      expect(p1.roles.count).to eq(2)
    end

    specify 'merge 3' do
      p1.merge_with(p2.id)
      expect(p2.roles.count).to eq(0)
    end

    specify 'merge 4' do
      p1.merge_with(p2.id)
      expect(Role.all.reload.map(&:person_id)).to contain_exactly(p1.id, p1.id)
    end

    specify 'merge 5' do
      p1.merge_with(p2.id)
      expect(p2.reload).to be_truthy
    end

    specify 'merge 6' do
      expect(p1.merge_with(p1.id)).to be_falsey
    end

    specify '#hard_merge 1' do
      p1.hard_merge(p2.id)
      expect{p2.reload}.to raise_error ActiveRecord::RecordNotFound
    end

    specify '#hard_merge 2' do
      expect(p1.hard_merge(p1.id)).to be_falsey
    end

    specify '#hard_merge 2' do
      expect(p1.hard_merge(999)).to be_falsey
    end
  end


  context 'years are combined' do
    context 'fills target year' do
      specify 'if empty' do
        person1.merge_with(person1b.id)
        expect(person1.year_born).to eq(person1b.year_born)
      end

      specify 'if source start earlier' do
        person1.update(year_active_start: person1b.year_active_start + 1)
        person1.merge_with(person1b.id)
        expect(person1.year_active_start).to eq(person1b.year_active_start)
      end

      specify 'if source start later' do
        person1.update!(year_active_start: person1b.year_active_start - 1)
        pre = person1.year_active_start
        person1.merge_with(person1b.id)
        expect(person1.year_active_start).to eq(pre)
      end

      specify 'if source end later' do
        person1.update(year_active_end: person1b.year_active_end - 1)
        person1.merge_with(person1b.id)
        expect(person1.year_active_end).to eq(person1b.year_active_end)
      end

      specify 'if source end earlier' do
        person1.update(year_active_end: person1b.year_active_end + 1)
        pre = person1.year_active_end
        person1.merge_with(person1b.id)
        expect(person1.year_active_end).to eq(pre)
      end
    end
  end

  context 'prefix is combined' do
    specify 'source is nil' do
      person1.update(prefix: nil)
      person1.merge_with(person1b.id)
      expect(person1.prefix).to eq(person1b.prefix)
    end
  end

  context 'suffix is combined' do

    # @tuckerjd whitespace and blank are converted to nil
    # on save, i.e. previous tests in this block
    # weren't doing anything new 
    specify 'source is nil' do
      person1.update(suffix: nil)
      # expect(person1.suffix).to eq(nil)
      person1.merge_with(person1b.id)
      expect(person1.suffix).to eq(person1b.suffix)
    end
  end

  context 'data_attributes' do

    before do
      person1.data_attributes << da1
      person1b.data_attributes << da2
    end

    specify 'data_attributes are combined' do
      person1.merge_with(person1b.id)
      person1.reload # TODO: Wondering why this 'reload' is requied?
      expect(person1.data_attributes.map(&:value)).to include('Mr.', 'Dr.')
    end

  end

  specify 'identifiers' do
    person1b.identifiers << id1
    person1b.save!
    person1.merge_with(person1b.id)
    expect(person1.identifiers).to include(id1)
  end

  specify 'notes' do
    person1b.notes << no1
    person1b.save!
    person1.merge_with(person1b.id)
    expect(person1.notes).to include(no1)
  end

  context 'alternate values' do
    specify 'creating' do
      av1
      person1.merge_with(person1b.id)
      expect(person1.alternate_values).to include(av1)
    end

    context 'different names' do
      specify 'first name' do
        person1b.update(first_name: 'Janco')
        person1.merge_with(person1b.id)
        expect(person1.alternate_values.last.value).to include(person1b.first_name)
      end

      specify 'first name with matching alternate value' do
        av2 # person1.first_name = January, person1.altername_value.first.value = Janco
        person1b.first_name = 'Janco'
        person1b.save!
        # this will try to add Janco as an alternate_value, but skip
        person1.merge_with(person1b.id)
        expect(person1.alternate_values.count).to eq(1)
      end

      specify 'last name' do
        person1b.last_name = 'Smyth'
        person1b.save!
        person1.merge_with(person1b.id)
        expect(person1.alternate_values.last.value).to include(person1b.last_name)
      end
    end
  end

  context 'names' do
    context 'r_person' do
      context 'truthyness' do
        specify 'nil first name' do
          person1b.first_name = nil
          person1b.save!
          trial = person1.merge_with(person1b.id)
          expect(trial).to be_truthy
        end
      end

      context 'success' do
        specify 'nil first name' do
          person1b.first_name = nil
          person1b.save!
          bfr = person1.first_name
          person1.merge_with(person1b.id)
          expect(person1.first_name).to eq(bfr)
        end
      end
    end

    context 'l_person' do
      context 'truthyness' do
        specify 'nil first name' do
          person1.first_name = nil
          person1.save!
          trial = person1.merge_with(person1b.id)
          expect(trial).to be_truthy
        end
      end

      context 'success' do
        specify 'nil first name' do
          person1.first_name = nil
          person1.save!
          person1.merge_with(person1b.id)
          expect(person1.first_name).to eq(person1b.first_name)
        end
      end
    end

    context 'cached' do
      specify 'cached get updated' do
        person1.update(prefix: nil)
        person1.merge_with(person1b.id)
        expect(person1.cached.include?('Dr.')).to be_truthy
      end
    end
  end

  context 'vetting' do
    context 'unvetted l_person' do
      specify 'unvetted r_person' do
        # An interesting anomoly occures when person1b is used in place of person1c.
        # In this context, use of person1b seems to result in person1 being converted to 'vetted'
        # (because person1b has been converted to 'vetted'),
        # even though it is otherwise *not* specifically set one way or the other during creation.
        # This seems to be an artifact of the fact that when a person is applied to a taxon name
        # as 'taxon_name_author', that person is (sometimes!) converted to 'vetted'.
        person1.merge_with(person1c.id)
        expect(person1.type.include?('Unv')).to be_truthy
      end

      specify 'vetted r_person' do
        person1.type = 'Person::Unvetted'
        person1.save!
        person1b.type = 'Person::Vetted'
        person1b.save!
        person1.merge_with(person1b.id)
        expect(person1.type.include?(':V')).to be_truthy
      end
    end
  end
end
