class TaxonNameRelationship::Icn::Unaccepting::Synonym::Heterotypic < TaxonNameRelationship::Icn::Unaccepting::Synonym

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000392'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icn::Unaccepting::Synonym) +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic)
  end

  def object_status
    'heterotypic senior synonym'
  end

  def subject_status
    'heterotypic synonym'
  end

  def self.assignment_method
    # bus.set_as_icn_heterotypic_synonym_of(aus)
    :icn_set_as_heterotypic_synonym_of
  end

  def self.inverse_assignment_method
    # aus.icn_heterotypic_synonym = bus
    :icn_heterotypic_synonym
  end

  def sv_specific_relationship
    s = subject_taxon_name
    o = object_taxon_name
    if (s.type_taxon_name == o.type_taxon_name && !s.type_taxon_name.nil? ) || (!s.get_primary_type.empty? && s.has_same_primary_type(o) )
      soft_validations.add(:type, "Subjective synonyms #{s.cached_html} and #{o.cached_html} should not have the same type")
    end
  end
end