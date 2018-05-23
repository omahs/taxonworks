#
# This is a top-level class documentation comment for the Alternate Value Controller
# RuboCop likes this
class AlternateValuesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_alternate_value, only: [:update, :destroy] # :edit removed from this list

  # GET /alternate_values
  # GET /alternate_values.json
  def index
    respond_to do |format|
      format.html {
        @recent_objects = AlternateValue.where(project_id: sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      }
      format.json {
        @alternate_values = Queries::AlternateValue::Filter.new(filter_params).all.limit(500)
          .where(project_id: sessions_current_project_id).order(:id)
      }
    end
  end

  def edit
    @alternate_value = AlternateValue.find_by_id(params[:id]).metamorphosize
  end

  # POST /alternate_values
  # POST /alternate_values.json
  def create
    @alternate_value = AlternateValue.new(alternate_value_params)
    respond_to do |format|
      @alternate_value.project_id = sessions_current_project_id if params[:project_members_only] == 'checked'

      if @alternate_value.save
        format.html { redirect_to url_for(@alternate_value.alternate_value_object.metamorphosize), notice: 'Alternate value was successfully created.' }
        format.json { render action: :show, status: :created, location: @alternate_value.metamorphosize }
      else
        format.html { render 'new', notice: 'Alternate value was NOT successfully created.' }
        format.json { render json: @alternate_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /alternate_values/1
  # PATCH/PUT /alternate_values/1.json
  def update
    respond_to do |format|
      @alternate_value.project_id = sessions_current_project_id if params[:project_members_only] == 'checked'
      if @alternate_value.update(alternate_value_params)
        format.html { redirect_to url_for(@alternate_value.alternate_value_object.metamorphosize), notice: 'Alternate value was successfully updated.' }
        format.json { render json: @alternate_value, status: :ok, location: @alternate_value.metamorphosize }
      else
        format.html { redirect_back(fallback_location: (request.referer || root_path), notice: 'Alternate value was NOT successfully updated.')}
        format.json { render json: @alternate_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /alternate_values/1
  # DELETE /alternate_values/1.json
  def destroy
    @alternate_value.destroy
    respond_to do |format|
      format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Alternate value was successfully destroyed.')}
      format.json { head :no_content }
    end
  end

  def list
    @alternate_values = AlternateValue.where(project_id: sessions_current_project_id).order(:alternate_value_object_type).page(params[:page])
  end

  # GET /alternate_values/search
  def search
    if params[:id].blank?
      redirect_to alternate_values_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      altval = AlternateValue.find_by_id(params[:id]).metamorphosize
      redirect_to url_for(altval.alternate_value_object.metamorphosize)
    end
  end

  def autocomplete
    @alternate_values = AlternateValue.find_for_autocomplete(params.merge(project_id: sessions_current_project_id))

    data = @alternate_values.collect do |t|
      str = render_to_string(partial: 'tag', locals: {alternate_value: t})
      {id:              t.id,
       label:           str,
       response_values: {params[:method] => t.id},
       label_html:      str
      }
    end

    render json: data
  end

  # GET /alternate_values/download
  def download
    send_data Download.generate_csv(AlternateValue.where(project_id: sessions_current_project_id)), type: 'text', filename: "alternate_values_#{DateTime.now}.csv"
  end

  # GET /alternate_values/:global_id/metadata
  def metadata
    @object = GlobalID::Locator.locate(params.require(:global_id))
  end

  private

  def set_alternate_value
    @alternate_value = AlternateValue.find(params[:id])
    render status: 404 if !@alternate_value.project_id.blank? && (sessions_current_project_id != @alternate_value.project_id)
  end

  def alternate_value_params
    params.require(:alternate_value).permit(
      :value, :type, :language_id,
      :alternate_value_object_type, :alternate_value_object_id,
      :alternate_value_object_attribute, :is_community_annotation, :annotated_global_entity
    )
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  # def alternate_value_params
  #   a_v_params = ActionController::Parameters.new({
  #
  #                                                 })
  #   a_v_params.require(:alternate_value).permit(:value, :type, :language_id, :alternate_value_object_type, :alternate_value_object_id, :alternate_value_object_attribute, :project_members_only)
  # end

  def filter_params
    params.permit(:value, :language_id, :type, :alternatevalue_object_attribute, 
                  :created_after, :created_before, on: [], by: [], id: []) 
  end

  def breakout_types(collection)
    collection
  end
end
