# Helpers for table rendering
module Workbench::TableHelper

  def fancy_th_tag(group: nil, name: '')
    content_tag(:th, data: { group: group } ) do
        content_tag(:span, name)
    end
  end
  
  # Hidden action links 
  # data-attributes:
  #  data-show
  #  data-edit
  #  data-delete
  #
  # This is very important, it must be set to make work the options for the context menu.
  # Use the class ".table-options" to hide those options on the table
  #
  def show_edit_delete_cells_tag(object)
    m = object.metamorphosize
    content_tag(:td, (link_to 'Show', m), class: 'table-options', data: {show: true}) +  
    content_tag(:td, edit_object_link(object), class: 'table-options', data: {edit: true}) +
    content_tag(:td, (link_to 'Destroy', m, method: :delete, data: {confirm: 'Are you sure?'}), class: 'table-options', data: {delete: true}) 
  end

end
