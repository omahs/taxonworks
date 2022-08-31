json.extract! depiction, :id, :depiction_object_id, :depiction_object_type,
:image_id,
:caption, :figure_label, :is_metadata_depiction,
:sled_image_id, :sled_image_x_position, :sled_image_y_position,
:svg_view_box,
:created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

if extend_response_with('figures')
  json.figures do
    json.medium depiction_tag(depiction, size: :medium)
    json.thumb depiction_tag(depiction, size: :thumb)
  end
end

if extend_response_with('image')
  json.image do
    json.partial! '/images/api/v1/attributes', image: depiction.image
  end
end

if extend_response_with('sqed_depiction')
  if depiction.sqed_depiction
    json.sqed_depiction do
      json.extract! depiction.sqed_depiction, :id, :boundary_color, :boundary_finder, :has_border, :layout, :metadata_map, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
    end
  end
end
