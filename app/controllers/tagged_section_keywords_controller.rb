class TaggedSectionKeywordsController < ApplicationController
  include DataControllerConfiguration

  before_action :set_tagged_section_keyword, only: [:update, :destroy]

  # POST /tagged_section_keywords
  # POST /tagged_section_keywords.json
  def create
    @tagged_section_keyword = TaggedSectionKeyword.new(tagged_section_keyword_params)

    respond_to do |format|
      if @tagged_section_keyword.save
        format.html { redirect_to :back, notice: 'Tagged section keyword was successfully created.' }
        format.json { render :show, status: :created, location: @tagged_section_keyword }
      else
        format.html { redirect_to :back, notice: 'Tagged section keyword was NOT successfully created.' }
        format.json { render json: @tagged_section_keyword.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tagged_section_keywords/1
  # PATCH/PUT /tagged_section_keywords/1.json
  def update
    respond_to do |format|
      if @tagged_section_keyword.update(tagged_section_keyword_params)
        format.html { redirect_to :back, notice: 'Tagged section keyword was successfully updated.' }
        format.json { render :show, status: :ok, location: @tagged_section_keyword }
      else
        format.html { redirect_to :back, notice: 'Tagged section keyword was NOT successfully updated.' }
        format.json { render json: @tagged_section_keyword.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tagged_section_keywords/1
  # DELETE /tagged_section_keywords/1.json
  def destroy
    @tagged_section_keyword.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Tagged section keyword was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tagged_section_keyword
      @tagged_section_keyword = TaggedSectionKeyword.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tagged_section_keyword_params
      params.require(:tagged_section_keyword).permit(:otu_page_layout_section_id, :keyword_id, :position)
    end
end
