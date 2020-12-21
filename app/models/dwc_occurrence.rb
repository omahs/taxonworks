# A Darwin Core Record for the Occurence core.  Field generated from Ruby dwc-meta, which references
# the same spec that is used in the IPT, and the Dwc Assistant.  Each record
# references a specific CollectionObject or AssertedDistribution.
#
# Important: This is a cache/index, data here are periodically (regenerated) from multiple tables in TW.
#
# TODO: The basisOfRecord CVTs are not super informative.
#    We know collection object is definitely 1:1 with PreservedSpecimen, however
#    AssertedDistribution could be HumanObservation (if source is person), or ... what? if
#    its a published record.  Seems we need a 'PublishedAssertation', just like we model the data.
#
# DWC attributes are camelCase to facilitate matching
# dwcClass is a replacement for the Rails reserved 'Class'
#
#
# All DC attributes (attributes not in DwcOccurrence::TW_ATTRIBUTES) in this table are namespaced to dc ("http://purl.org/dc/terms/", "http://rs.tdwg.org/dwc/terms/")
#
class DwcOccurrence < ApplicationRecord
  self.inheritance_column = nil

  include Housekeeping

  DC_NAMESPACE = 'http://rs.tdwg.org/dwc/terms/'.freeze

  # Not yet implemented, but likely needed
  # ? :id
  TW_ATTRIBUTES = [
    :id,
    :project_id,
    :created_at,
    :updated_at,
    :created_by_id,
    :updated_by_id,
    :dwc_occurrence_object_type,
    :dwc_occurence_object_id
  ].freeze

  HEADER_CONVERTERS = {
    'dwcClass' => 'class',
  }.freeze

  CSV::HeaderConverters[:dwc_headers] = lambda do |field|
    d = DwcOccurrence::HEADER_CONVERTERS[field]
    d ? d : field
  end

  belongs_to :dwc_occurrence_object, polymorphic: true, inverse_of: :dwc_occurrence
  has_one :collecting_event, through: :dwc_occurrence_object, inverse_of: :dwc_occurrences

  before_validation :set_basis_of_record
  validates_presence_of :basisOfRecord

  validates :dwc_occurrence_object, presence: true
  validates_uniqueness_of :dwc_occurrence_object_id, scope: [:dwc_occurrence_object_type, :project_id]

  # @return [ActiveRecord::Relation]
  def self.collection_objects_join
    a = arel_table
    b = ::CollectionObject.arel_table 
    j = a.join(b).on(a[:dwc_occurrence_object_type].eq('CollectionObject').and(a[:dwc_occurrence_object_id].eq(b[:id])))
    joins(j.join_sources)
  end

 # @return [Array]
  #   of column names as symbols that are blank in *ALL* projects (not just this one)
  def self.empty_fields
    empty_in_all_projects =  ActiveRecord::Base.connection.execute("select attname
    from pg_stats
    where tablename = 'dwc_occurrences'
    and most_common_vals is null
    and most_common_freqs is null
    and histogram_bounds is null
    and correlation is null
    and null_frac = 1;").pluck('attname').map(&:to_sym)

    empty_in_all_projects #  - target_columns
  end

  # @return [Array]
  #   of symbols
  def self.target_columns
    [:id, :basisOfRecord] + CollectionObject::DwcExtensions::DWC_OCCURRENCE_MAP.keys
  end

  # @return [Array] 
  #   of symbols
  # TODO: 
  def self.excluded_columns
    ::DwcOccurrence.columns.collect{|c| c.name.to_sym} - self.target_columns 
  end

  # @return [Scope]
  #   the columns inferred to have data
  def self.computed_columns
    select(target_columns)
  end

  def basis
    case dwc_occurrence_object_type
    when 'CollectionObject'
      return 'PreservedSpecimen'
    when 'AssertedDistribution'
      case dwc_occurrence_object.source.try(:type)
      when 'Source::Bibtex'
        return 'Occurrence'
      when 'Source::Human'
        return 'HumanObservation'
      end
    end
    'Undefined'
  end

  # Is a spot check not a join/query based check.
  # @return [Boolean]
  def stale?
    case dwc_occurrence_object_type

    when 'CollectionObject'
      t = [
        dwc_occurrence_object.updated_at,
        dwc_occurrence_object.collecting_event&.updated_at,
        dwc_occurrence_object&.taxon_determinations&.first&.updated_at
      ].compact!
      t.sort.first > (updated_at || Time.now)
    else # AssertedDistribution
      dwc_occurrence_object.updated_at > updated_at
    end
  end

  protected

  def set_basis_of_record
    write_attribute(:basisOfRecord, basis)
  end

end
