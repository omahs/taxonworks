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

RSpec.describe DescriptorsController, type: :controller do
  before(:each){
    sign_in
  }

  # This should return the minimal set of attributes required to create a valid
  # Descriptor. As you add validations to Descriptor, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    strip_housekeeping_attributes(FactoryGirl.build(:valid_descriptor).attributes)
  }

  let(:invalid_attributes) {
    {name: nil}
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # DescriptorsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all descriptors as @descriptors" do
      descriptor = Descriptor.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(assigns(:recent_objects)).to eq([descriptor])
    end
  end

  describe "GET #show" do
    it "assigns the requested descriptor as @descriptor" do
      descriptor = Descriptor.create! valid_attributes
      get :show, params: {id: descriptor.to_param}, session: valid_session
      expect(assigns(:descriptor)).to eq(descriptor)
    end
  end

  describe "GET #new" do
    it "assigns a new descriptor as @descriptor" do
      get :new, params: {}, session: valid_session
      expect(assigns(:descriptor)).to be_a_new(Descriptor)
    end
  end

  describe "GET #edit" do
    it "assigns the requested descriptor as @descriptor" do
      descriptor = Descriptor.create! valid_attributes
      get :edit, params: {id: descriptor.to_param}, session: valid_session
      expect(assigns(:descriptor)).to eq(descriptor)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Descriptor" do
        expect {
          post :create, params: {descriptor: valid_attributes}, session: valid_session
        }.to change(Descriptor, :count).by(1)
      end

      it "assigns a newly created descriptor as @descriptor" do
        post :create, params: {descriptor: valid_attributes}, session: valid_session
        expect(assigns(:descriptor)).to be_a(Descriptor)
        expect(assigns(:descriptor)).to be_persisted
      end

      it "redirects to the created descriptor" do
        post :create, params: {descriptor: valid_attributes}, session: valid_session
        expect(response).to redirect_to(Descriptor.last.metamorphosize)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved descriptor as @descriptor" do
        post :create, params: {descriptor: invalid_attributes}, session: valid_session
        expect(assigns(:descriptor)).to be_a_new(Descriptor)
      end

      it "re-renders the 'new' template" do
        post :create, params: {descriptor: invalid_attributes}, session: valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {name: 'new name'}
      }

      it "updates the requested descriptor" do
        descriptor = Descriptor.create! valid_attributes
        put :update, params: {id: descriptor.to_param, descriptor: new_attributes}, session: valid_session
        descriptor.reload
        expect(descriptor.name == new_attributes['name'])
      end

      it "assigns the requested descriptor as @descriptor" do
        descriptor = Descriptor.create! valid_attributes
        put :update, params: {id: descriptor.to_param, descriptor: valid_attributes}, session: valid_session
        expect(assigns(:descriptor)).to eq(descriptor)
      end

      it "redirects to the descriptor" do
        descriptor = Descriptor.create! valid_attributes
        put :update, params: {id: descriptor.to_param, descriptor: valid_attributes}, session: valid_session
        expect(response).to redirect_to(descriptor.metamorphosize)
      end
    end

    context "with invalid params" do
      it "assigns the descriptor as @descriptor" do
        descriptor = Descriptor.create! valid_attributes
        put :update, params: {id: descriptor.to_param, descriptor: invalid_attributes}, session: valid_session
        expect(assigns(:descriptor)).to eq(descriptor)
      end

      it "re-renders the 'edit' template" do
        descriptor = Descriptor.create! valid_attributes
        put :update, params: {id: descriptor.to_param, descriptor: invalid_attributes}, session: valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested descriptor" do
      descriptor = Descriptor.create! valid_attributes
      expect {
        delete :destroy, params: {id: descriptor.to_param}, session: valid_session
      }.to change(Descriptor, :count).by(-1)
    end

    it "redirects to the descriptors list" do
      descriptor = Descriptor.create! valid_attributes
      delete :destroy, params: {id: descriptor.to_param}, session: valid_session
      expect(response).to redirect_to(descriptors_url)
    end
  end

end
