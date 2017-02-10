class TopicsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  def list
    topics = Topic.order(:name).where(project_id: sessions_current_project_id).all

    data = topics.collect do |t|
      str = t.name + ": " + t.definition
      { id: t.id,
        label:  t.name,
        definition: t.definition, 
        color: t.css_color 
      }
    end

    render :json => data
  end

  # POST /controlled_vocabulary_terms
  # POST /controlled_vocabulary_terms.json
  def create
    @controlled_vocabulary_term = ControlledVocabularyTerm.new(controlled_vocabulary_term_params)
    respond_to do |format|
      if @controlled_vocabulary_term.save
        msg = "#{@controlled_vocabulary_term.type} '#{@controlled_vocabulary_term.name}' was successfully created."

        if !params.permit(:return_path)[:return_path].blank?
          # case - coming from otu -> new tag -> new cvt -> back to tag/new
          redirect_url = params.permit(:return_path)[:return_path] + "&tag[keyword_id]=#{@controlled_vocabulary_term.to_param}"
        elsif request.env['HTTP_REFERER'].include?('controlled_vocabulary_terms/new')
          # case - coming from cvt index -> cvt/new
          redirect_url = controlled_vocabulary_term_path(@controlled_vocabulary_term)
        else
          # case - coming from task -> return to task
          redirect_url = :back
        end

        format.html { redirect_to redirect_url, notice: msg } # !! new behaviour to test
        format.json { render action: 'show', status: :created, location: @controlled_vocabulary_term.metamorphosize }

      else
        format.html {
          flash[:notice] = 'Controlled vocabulary term NOT successfully created.'
          if redirect_url == :back
            redirect_to :back
          else
            render action: 'new'
          end
        }
        format.json { render json: @controlled_vocabulary_term.errors, status: :unprocessable_entity }
      end
    end
  end



  # TODO: This format very different, should it be made same as other autocompletes?
  def autocomplete
    topics = Topic.find_for_autocomplete(params.merge(project_id: sessions_current_project_id))

    data = topics.collect do |t|
      str = t.name + ": " + t.definition
      {id:              t.id,
       label:           str,
       response_values: {
         params[:method] => t.id},
       label_html:      str
      }
    end

    render :json => data
  end

  def lookup_topic
    @topics = Topic.find_for_autocomplete(params.merge(project_id: sessions_current_project_id))
    render(:json => @topics.collect { |t|
      {
        label:     t.name,
        object_id: t.id,
        definition: t.definition
      }
    })
  end

  def get_definition
    @topic = Topic.find(params[:id])
    render(:json => {definition: @topic.definition})
  end

end
