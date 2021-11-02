class Export::Graph

  NODE_COLORS = {
    'Person' => '#009688',
    'CollectionObject' => '#2196F3',
    'TaxonName' => '#E91E63',
    'CollectingEvent' => '#7E57C2',
    'TaxonDetermination' => '#FF9800',
    'Identifier' => '#EF6C00',
    'Otu' =>'#4CAF50',
    'User' => '#F44336',
    'ControlledVocabularyTerm' => '#CDDC39',
    'BiologicalRelationship' => '#9C27B0',
    'Repository' => '#009688',
    'Observation' => '#CDDC39',
    'Citation' => '#009688',
  }

  NODE_SHAPES = {
    'Person' => 'person',
    'CollectionObject' => 'circle',
    'TaxonName' => 'square',
    'CollectingEvent' => 'circle',
    'TaxonDetermination' => nil,
    'Identifier' => 'triangle',
    'Otu' => 'hexagon',
    'User' => 'person',
    'ControlledVocabularyTerm' => nil,
    'BiologicalRelationship' => 'square' ,
    'Observation' => 'square',
    'Citation' => 'square',
    'Repository' => 'circle'
  }

  RENDERABLE_ANNOTATIONS = []

  attr_accessor :nodes
  attr_accessor :edges

  attr_accessor :draw_annotations

  # @params object [An AR record, nil]
  #   the "base" of the object, if rooted
  def initialize(object: nil, annotations_to_draw: RENDERABLE_ANNOTATIONS )
    @draw_annotations = annotations_to_draw
    @nodes = []
    @edges = []

    add(object) if !object.nil?
  end

  def nodes
    @nodes.compact.uniq
  end

  def edges
    @edges.compact.uniq
  end

  def to_json(include_stats: true)
    h =  {
      nodes: nodes,
      edges: edges
    }

    h[:stats] = stats if include_stats
    return h
  end

  def stats
    return {
      nodes: nodes.count,
      edges: edges.count
    }
  end


  def add(object, object_origin = nil, edge_label: nil, edge_link: nil)
    add_node(object)
    add_edge(object_origin, object, edge_label: edge_label, edge_link: edge_link) if !object_origin.nil?
  end

  # TODO factor view options out
  def add_node(object, citations: true, identifiers: true)
    @nodes.push graph_node(object)

    if citations && object.respond_to?(:citations)
      object.citations.each do |c|
        add_node(c, citations: false, identifiers: false)
        add_node(c.source, citations: false, identifiers: true)

        add_edge(c, object)
        add_edge(c.source, c)

        if c.source.is_bibtex?
          c.source.authors.each do |p|
            add_node(p, citations: false, identifiers: true)
            add_edge(p, c.source)
          end
        end
      end
    end

    if identifiers && object.respond_to?(:identifiers)
      object.identifiers.each do |i|
        add_node(i, citations: false, identifiers: false)
        add_edge(i, object)
      end
    end
  end

  def add_edge(object, object_origin = nil, edge_label: nil, edge_link: nil)
    @edges.push graph_edge(object_origin, object, edge_label: edge_label, edge_link: edge_link)
  end

  def graph_node(object, node_link: nil)
    return nil if object.nil?
    b = object.class.base_class.name
    h = {
      id: object.to_global_id.to_s,
      name:  ApplicationController.helpers.label_for(object) || object.class.base_class.name,
      color: NODE_COLORS[b] || '#000000'
    }

    h[:shape] = NODE_SHAPES[b] if !NODE_SHAPES[b].nil?
    h[:link] = node_link || Rails.application.routes.url_helpers.object_graph_task_path(global_id: object.to_global_id.to_s)
    h
  end

  def graph_edge(start_object, end_object, edge_label: nil, edge_link: nil)
    return nil if start_object.nil? || end_object.nil?
    h = {
      start_id: start_object.to_global_id.to_s,
      end_id: end_object.to_global_id.to_s
    }

    # TODO: change label to name
    h[:label] = edge_label unless edge_label.blank?
    h[:link] = edge_link unless edge_link.blank?
    h
  end

  # @return True
  # !param graph [Export::Graph]
  # Merges the edges and nodes from another graph to this one
  def merge(graph)
    @nodes += graph.nodes
    @edges += graph.edges
    @nodes.uniq!
    @edges.uniq!
    true
  end

end
