require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe RepositoriesController, :type => :controller do
  before(:each) {
    sign_in
  }

  # This should return the minimal set of attributes required to create a valid
  # Georeference. As you add validations to Georeference be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    strip_housekeeping_attributes(FactoryGirl.build(:valid_repository).attributes)
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # RepositoriesController. Be sure to keep this updated too.
  let(:valid_session) {{}}

  describe 'GET index' do
    it 'assigns all repositories as @repositories' do
      repository = Repository.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(assigns(:repositories)).to include(repository)
    end
  end

  describe 'GET show' do
    it 'assigns the requested repository as @repository' do
      repository = Repository.create! valid_attributes
      get :show, params: {id: repository.to_param}, session: valid_session
      expect(assigns(:repository)).to eq(repository)
    end
  end

  describe 'GET new' do
    it 'assigns a new repository as @repository' do
      get :new, params: {}, session: valid_session
      expect(assigns(:repository)).to be_a_new(Repository)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested repository as @repository' do
      repository = Repository.create! valid_attributes
      get :edit, params: {id: repository.to_param}, session: valid_session
      expect(assigns(:repository)).to eq(repository)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new Repository' do
        expect {
          post :create, params: {:repository => valid_attributes}, session: valid_session
        }.to change(Repository, :count).by(1)
      end

      it 'assigns a newly created repository as @repository' do
        post :create, params: {:repository => valid_attributes}, session: valid_session
        expect(assigns(:repository)).to be_a(Repository)
        expect(assigns(:repository)).to be_persisted
      end

      it 'redirects to the created repository' do
        post :create, params: {:repository => valid_attributes}, session: valid_session
        expect(response).to redirect_to(Repository.last)
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved repository as @repository' do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Repository).to receive(:save).and_return(false)
        post :create, params: {:repository => {'name' => 'invalid value'}}, session: valid_session
        expect(assigns(:repository)).to be_a_new(Repository)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Repository).to receive(:save).and_return(false)
        post :create, params: {:repository => {'name' => 'invalid value'}}, session: valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested repository' do
        repository = Repository.create! valid_attributes
        # Assuming there are no other repositories in the database, this
        # specifies that the Repository created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        update_params = ActionController::Parameters.new({'name' => 'MyString'}).permit(:name)
        expect_any_instance_of(Repository).to receive(:update).with(update_params)
        put :update, params: {id: repository.to_param, :repository => {'name' => 'MyString'}}, session: valid_session
      end

      it 'assigns the requested repository as @repository' do
        repository = Repository.create! valid_attributes
        put :update, params: {id: repository.to_param, :repository => valid_attributes}, session: valid_session
        expect(assigns(:repository)).to eq(repository)
      end

      it 'redirects to the repository' do
        repository = Repository.create! valid_attributes
        put :update, params: {id: repository.to_param, :repository => valid_attributes}, session: valid_session
        expect(response).to redirect_to(repository)
      end
    end

    describe 'with invalid params' do
      it 'assigns the repository as @repository' do
        repository = Repository.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Repository).to receive(:save).and_return(false)
        put :update, params: {id: repository.to_param, :repository => {'name' => 'invalid value'}}, session: valid_session
        expect(assigns(:repository)).to eq(repository)
      end

      it "re-renders the 'edit' template" do
        repository = Repository.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Repository).to receive(:save).and_return(false)
        put :update, params: {id: repository.to_param, :repository => {'name' => 'invalid value'}}, session: valid_session
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested repository' do
      repository = Repository.create! valid_attributes
      expect {
        delete :destroy, params: {id: repository.to_param}, session: valid_session
      }.to change(Repository, :count).by(-1)
    end

    it 'redirects to the repositories list' do
      repository = Repository.create! valid_attributes
      delete :destroy, params: {id: repository.to_param}, session: valid_session
      expect(response).to redirect_to(repositories_url)
    end
  end
end
