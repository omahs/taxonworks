# Notes:
#  - if you want to .create a protonym and not build the related ancestors ancestors set the parent to nil
FactoryGirl.define do

  trait :mostly_empty_protonym do
    cached_name nil
    cached_author_year nil
    source_id nil
    year_of_publication nil
    verbatim_author nil
  end

  trait :parent_is_root do
    parent {
      p =  Protonym.where(parent_id: nil) 
      if p.blank?
        name = FactoryGirl.create(:root_taxon_name)
      else
        name = p.first
      end
      name 
    }
  end

  factory :protonym, traits: [:housekeeping, :mostly_empty_protonym] do

    # Relationship provided
    factory :relationship_family, class: Protonym do
      name 'Erythroneuridae'
      association :parent, factory: :iczn_kingdom
      year_of_publication 1850
      verbatim_author 'Say'
      rank_class Ranks.lookup(:iczn, 'family')
    end

    factory :relationship_genus do
      name 'Erythroneura'
      association :parent, factory: :relationship_family
      year_of_publication 1850
      verbatim_author 'Say'
      rank_class Ranks.lookup(:iczn, 'Genus')
    end

    factory :relationship_species do
      name 'vitis'
      association :parent, factory: :relationship_genus
      year_of_publication 1900
      verbatim_author 'McAtee'
      rank_class Ranks.lookup(:iczn, 'SPECIES')
    end

    # ICZN taxa
    factory :valid_protonym do
      name 'Aidae'
      rank_class Ranks.lookup(:iczn, 'Family')
      association :parent, factory: :root_taxon_name
    end

    factory :root_taxon_name do
      name 'Root'
      rank_class  NomenclaturalRank
      parent_id nil
    end

    # ICZN names

    factory :iczn_kingdom, traits: [:parent_is_root] do
      mostly_empty_protonym
      name 'Animalia'
      cached_higher_classification 'Animalia'
      association :parent, factory: :root_taxon_name
      rank_class Ranks.lookup(:iczn, 'kingdom')
    end

    factory :iczn_phylum do
      name 'Arthropoda'
      association :parent, factory: :iczn_kingdom
      rank_class Ranks.lookup(:iczn, 'phylum')
    end

    factory :iczn_class do
      name 'Insecta'
      association :parent, factory: :iczn_phylum
      rank_class Ranks.lookup(:iczn, 'class')
    end

    factory :iczn_order do
      name 'Hemiptera'
      association :parent, factory: :iczn_class
      rank_class Ranks.lookup(:iczn, 'order')
    end

    factory :iczn_family do
      name 'Cicadellidae'
      association :parent, factory: :iczn_order
      association :source, factory: :valid_bibtex_source
      year_of_publication 1800
      verbatim_author 'Say'
      rank_class Ranks.lookup(:iczn, 'Family')
    end

    factory :iczn_subfamily do
      name 'Typhlocybinae'
      association :parent, factory: :iczn_family
      association :source, factory: :valid_bibtex_source
      year_of_publication 1800
      verbatim_author 'Say'
      rank_class Ranks.lookup(:iczn, 'Subfamily')
    end

    factory :iczn_tribe do
      name 'Erythroneurini'
      association :parent, factory: :iczn_subfamily
      association :source, factory: :valid_bibtex_source
      year_of_publication 1800
      verbatim_author 'Say'
      rank_class Ranks.lookup(:iczn, 'Tribe')
    end

    factory :iczn_subtribe do
      name 'Erythroneurina'
      association :parent, factory: :iczn_tribe
      association :source, factory: :valid_bibtex_source
      year_of_publication 1800
      verbatim_author 'Say'
      rank_class Ranks.lookup(:iczn, 'Subtribe')
    end

    factory :iczn_genus do
      name 'Erythroneura'
      association :parent, factory: :iczn_subtribe
      association :source, factory: :valid_bibtex_source
      year_of_publication 1850
      verbatim_author 'Say'
      rank_class Ranks.lookup(:iczn, 'Genus')
    end

    factory :iczn_subgenus do
      name 'Erythroneura'
      association :parent, factory: :iczn_genus
      association :source, factory: :valid_bibtex_source
      year_of_publication 1850
      verbatim_author 'Say'
      rank_class Ranks.lookup(:iczn, 'Subgenus')
    end

    factory :iczn_species do
      name 'vitis'
      association :parent, factory: :iczn_subgenus
      association :source, factory: :valid_bibtex_source
      year_of_publication 1900
      verbatim_author 'McAtee'
      rank_class Ranks.lookup(:iczn, 'SPECIES')
    end

    factory :iczn_subspecies do
      name 'ssp'
      association :parent, factory: :iczn_species
      association :source, factory: :valid_bibtex_source
      year_of_publication 1900
      verbatim_author 'McAtee'
      rank_class Ranks.lookup(:iczn, 'subspecies')
    end

    #ICN name

    factory :icn_kingdom, traits: [:parent_is_root] do
      name 'Plantae'
      association :parent, factory: :root_taxon_name
      rank_class Ranks.lookup(:icn, 'kingdom')
    end

    factory :icn_phylum do
      name 'Aphyta'
      association :parent, factory: :icn_kingdom
      rank_class Ranks.lookup(:icn, 'phylum')
    end

    factory :icn_subphylum do
      name 'Aphytina'
      association :parent, factory: :icn_phylum
      rank_class Ranks.lookup(:icn, 'subphylum')
    end

    factory :icn_class do
      name 'Aopsida'
      association :parent, factory: :icn_subphylum
      rank_class Ranks.lookup(:icn, 'class')
    end

    factory :icn_subclass do
      name 'Aidae'
      association :parent, factory: :icn_class
      rank_class Ranks.lookup(:icn, 'subclass')
    end

    factory :icn_order do
      name 'Aales'
      association :parent, factory: :icn_subclass
      rank_class Ranks.lookup(:icn, 'order')
    end

    factory :icn_suborder do
      name 'Aineae'
      association :parent, factory: :icn_order
      rank_class Ranks.lookup(:icn, 'suborder')
    end

    factory :icn_family do
      name 'Aaceae'
      association :parent, factory: :icn_suborder
      rank_class Ranks.lookup(:icn, 'family')
    end

    factory :icn_subfamily do
      name 'Aoideae'
      association :parent, factory: :icn_family
      rank_class Ranks.lookup(:icn, 'subfamily')
    end

    factory :icn_tribe do
      name 'Aeae'
      association :parent, factory: :icn_subfamily
      rank_class Ranks.lookup(:icn, 'Tribe')
    end

    factory :icn_subtribe do
      name 'Ainae'
      association :parent, factory: :icn_tribe
      rank_class Ranks.lookup(:icn, 'subtribe')
    end

    factory :icn_genus do
      name 'Aus'
      association :parent, factory: :icn_subtribe
      year_of_publication 1850
      verbatim_author 'John'
      rank_class Ranks.lookup(:icn, 'Genus')
    end

    factory :icn_subgenus do
      name 'Aus'
      association :parent, factory: :icn_genus
      year_of_publication 1850
      verbatim_author 'Say'
      rank_class Ranks.lookup(:icn, 'Subgenus')
    end

    factory :icn_section do
      name 'Aus'
      association :parent, factory: :icn_subgenus
      year_of_publication 1850
      verbatim_author 'Say'
      rank_class Ranks.lookup(:icn, 'section')
    end

    factory :icn_series do
      name 'Aus'
      association :parent, factory: :icn_section
      year_of_publication 1850
      verbatim_author 'Say'
      rank_class Ranks.lookup(:icn, 'series')
    end

    factory :icn_species do
      name 'aaa'
      association :parent, factory: :icn_series
      association :source, factory: :valid_bibtex_source
      year_of_publication 1900
      verbatim_author 'McAtee'
      rank_class Ranks.lookup(:icn, 'SPECIES')
    end

    factory :icn_subspecies do
      name 'bbb'
      association :parent, factory: :icn_species
      association :source, factory: :valid_bibtex_source
      year_of_publication 1900
      verbatim_author 'McAtee'
      rank_class Ranks.lookup(:icn, 'subspecies')
    end

    factory :icn_variety do
      name 'ccc'
      association :parent, factory: :icn_subspecies
      association :source, factory: :valid_bibtex_source
      year_of_publication 1900
      verbatim_author 'McAtee'
      rank_class Ranks.lookup(:icn, 'variety')
    end
  end
end
