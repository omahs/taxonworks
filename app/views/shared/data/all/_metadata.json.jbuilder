json.object_tag object_tag(object)
json.object_label label_for(object)

json.global_id object.persisted? ? object.to_global_id.to_s : nil

json.base_class object.class.base_class.name

json.url url_for(only_path: false, format: :json)

json.object_url url_for(metamorphosize_if(object))

if object.respond_to?(:origin_citation) && object.origin_citation
  json.origin_citation do
    json.id object.origin_citation.id
    json.pages object.origin_citation.pages

    json.partial! '/shared/data/all/metadata', object: object.origin_citation

    json.source do 
      json.partial! '/sources/attributes', source: object.origin_citation.source
    end
  end
end

if object.respond_to?(:pinned?) && object.pinned?(sessions_current_user)
  json.pinboard_item do
    json.id object.pinboard_item_for(sessions_current_user).id
  end
end
