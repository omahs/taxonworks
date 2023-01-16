# Helpers and facets for queries that reference Protocols.
#
module Queries::Concerns::Protocols

  extend ActiveSupport::Concern

  def self.permit(params)
    params.permit(
      :protocols,
      :protocol_id_or,
      :protocol_id_and
    )
  end

  included do
    # @return [Array]
    # @params protocol_id_and [:protocol_id_and | [protocol_id_and, .. ] ]
    attr_accessor :protocol_id_and

    # @return [Array]
    # @params protocol_id_or [:protocol_id_or | [protocol_id_or, .. ] ]
    attr_accessor :protocol_id_or

    # @return [Boolean, nil]
    # @params protocols ['true', 'false', nil]
    attr_accessor :protocols

    def protocol_id_and
      [@protocol_id_and].flatten.compact.uniq
    end

    def protocol_id_or
      [@protocol_id_or].flatten.compact.uniq
    end

    # TODO: why here?
    def protocol_ids=(value = [])
      @protocol_ids = value
    end
  end

  def set_protocols_params(params)
    @protocol_id_and = params[:protocol_id_and]
    @protocol_id_or = params[:protocol_id_or]
    @protocols = boolean_param(params, :protocols)
  end

  # @return [Arel::Table]
  def protocol_relationship_table 
    ::ProtocolRelationship.arel_table
  end

  def self.merge_clauses
    [
      :protocol_id_facet,
      :protocol_facet,
    ]
  end 

  # @return
  #   all sources that match all _and ids OR any OR id
  def protocol_id_facet
    return nil if protocol_id_or.empty? && protocol_id_and.empty?
    k = table.name.classify.safe_constantize

    a = matching_protocol_id_or
    b = matching_protocol_id_and

    if a.nil?
      b
    elsif b.nil?
      a
    else
      k.from("( (#{a.to_sql}) UNION (#{b.to_sql})) as #{table.name}")
    end
  end

  def protocol_facet
    return nil if protocols.nil?
    if protocols
      referenced_table.joins(:protocols).distinct
    else
      referenced_table.where.mising(:protocols)
    end
  end

  private

  # merge
  def matching_protocol_id_or
    return nil if protocol_id_or.empty?
    k = table.name.classify.safe_constantize
    t = ::ProtocolRelationship.arel_table

    w = t[:protocol_relationship_object_id].eq(table[:id]).and( t[:protocol_relationship_object_type].eq(table.name.classify))
    w = w.and( t[:protocol_id].eq_any(protocol_id_or) ) if protocol_id_or.any? 

    k.where( ::ProtocolRelationship.where(w).arel.exists )
  end

  # merge
  def matching_protocol_id_and
    return nil if protocol_id_and.empty?
    l = table.name
    k = l.classify.safe_constantize
    t = ::ProtocolRelationship.arel_table

    a = table.alias("k_#{l}")

    b = table.project(a[Arel.star]).from(a)
      .join(t)
      .on(
        t[:protocol_relationship_object_id].eq(a[:id]),
        t[:protocol_relationship_object_type].eq(k.name)
      )

    i = 0

    protocol_id_and.each do |j|
      t_a = t.alias("tk_#{l[0..5]}_#{i}")
      b = b.join(t_a).on(
        t_a['protocol_relationship_object_id'].eq(a['id']),
        t_a[:protocol_relationship_object_type].eq(k),
        t_a[:protocol_id].eq(j)
      )

      i += 1
    end

    b = b.group(a[:id]).having(t[:protocol_id].count.gteq(protocol_id_and.count))
    b = b.as("#{l}_ai")

    k.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b[:id].eq(table[:id]))))
  end



end
