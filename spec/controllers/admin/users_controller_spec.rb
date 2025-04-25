# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::UsersController, type: :controller do
  before(:each) do
    @admin = FactoryBot.create(:user, role: "admin")
    @regular_user = FactoryBot.create(:user, role: "driver")
    sign_in @admin
  end

  describe "GET #index" do
    it "assigns all users to @users" do
      get :index
      expect(assigns(:users)).to include(@admin, @regular_user)
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe "GET #edit" do
    it "assigns the user to @user" do
      get :edit, params: { id: @regular_user.id }
      expect(assigns(:user)).to eq(@regular_user)
    end

    it "renders the edit template" do
      get :edit, params: { id: @regular_user.id }
      expect(response).to render_template(:edit)
    end
  end

  describe "PATCH #update" do
    context "with valid attributes" do
      it "updates the user's role" do
        patch :update, params: { id: @regular_user.id, user: { role: "dispatcher" } }
        expect(@regular_user.reload.role).to eq("dispatcher")
      end

      it "redirects to index with a success notice" do
        patch :update, params: { id: @regular_user.id, user: { email: "newemail@example.com" } }
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:notice]).to eq("User updated successfully.")
      end
    end

    context "with invalid attributes" do
      it "renders edit template again" do
        allow_any_instance_of(User).to receive(:update).and_return(false)
        patch :update, params: { id: @regular_user.id, user: { email: "" } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE #destroy" do
    it "deletes the user" do
      expect {
        delete :destroy, params: { id: @regular_user.id }
      }.to change(User, :count).by(-1)
    end

    it "redirects to index with success message" do
      delete :destroy, params: { id: @regular_user.id }
      expect(response).to redirect_to(admin_users_path)
      expect(flash[:notice]).to eq("User deleted successfully.")
    end

    it "does not allow deleting the last admin and shows an alert" do
      expect(User.where(role: "admin").count).to eq(1)

      delete :destroy, params: { id: @admin.id }

      expect(response).to redirect_to(admin_users_path)
      expect(flash[:alert]).to eq("Cannot delete the last admin user.")
      expect(User.exists?(@admin.id)).to be true
    end
  end

  describe "DELETE #destroy_unassigned" do
    it "deletes all users with no assigned role" do
      FactoryBot.create(:user, role: nil)
      FactoryBot.create(:user, role: "")
      FactoryBot.create(:user, role: "dispatcher") # Should not be deleted
      FactoryBot.create(:user, role: "driver") # Should not be deleted

      expect {
        delete :destroy_unassigned
      }.to change { User.where(role: [nil, ""]).count }.from(2).to(0)

      expect(response).to redirect_to(admin_users_path)
      expect(flash[:notice]).to eq("2 unassigned users removed.")
    end

    it "does not delete users with valid roles" do
      driver1 = FactoryBot.create(:user, role: "driver")
      dispatcher1 = FactoryBot.create(:user, role: "dispatcher")

      delete :destroy_unassigned

      expect(User.exists?(driver1.id)).to be true
      expect(User.exists?(dispatcher1.id)).to be true
    end

    it "redirects to admin_users_path with proper notice when no unassigned users" do
      FactoryBot.create(:user, role: "admin")
      FactoryBot.create(:user, role: "driver")

      delete :destroy_unassigned

      expect(response).to redirect_to(admin_users_path)
      expect(flash[:notice]).to eq("0 unassigned users removed.")
    end
  end

  describe "access control" do
    it "redirects non-admin user to root with alert" do
      sign_out @admin
      sign_in @regular_user
      get :index
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Access denied.")
    end

    it "does not allow non-admins to access destroy_unassigned" do
      sign_out @admin
      sign_in @regular_user

      delete :destroy_unassigned
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Access denied.")
    end
  end
end
