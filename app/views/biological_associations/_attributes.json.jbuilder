json.partial! '/biological_associations/base_attributes', biological_association: biological_association
json.partial! '/shared/data/all/metadata', object: biological_association

if extend_response_with('triple_metadata')

  json.biological_relationship do
    json.partial! '/biological_relationships/attributes', biological_relationship: biological_association.biological_relationship
  end

  json.subject do
    json.partial! '/shared/data/all/metadata', object: biological_association.biological_association_subject, extensions: false

    if extend_response_with('family_names')
      json.family_name biological_association.biological_association_subject.taxonomy['family']
    end
  end

  json.object do
    json.partial! '/shared/data/all/metadata', object: biological_association.biological_association_object, extensions: false

    if extend_response_with('family_names')
      json.family_name biological_association.biological_association_object.taxonomy['family']
    end
  end
end

if extend_response_with('citations')
  json.citations do
    json.array! biological_association.citations.reload, partial: '/citations/attributes', as: :citation
  end
end
