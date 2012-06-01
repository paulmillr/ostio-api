module V1
  class UsersController < ApplicationController
    before_filter :check_sign_in, except: [:index, :show]
    before_filter :check_permissions, except: [:index, :show, :show_current]

    def check_permissions
      if @user.type == 'User'
        not_authorized unless current_user == @user
      else
        not_authorized unless @user.owners.include?(current_user)
      end
    end

    def to_json(thing)
      thing.as_json
    end

    # GET /users/1
    # GET /users/1.json
    def show
      @user = User.find_by_login!(params[:id])
      render json: to_json(@user)
    end

    def show_current
      @user = current_user
      render json: to_json(@user)
    end

    # PATCH/PUT /users/1
    # PATCH/PUT /users/1.json
    def update
      @user = User.find_by_login!(params[:id])

      if @user.update_attributes(params[:user])
        head :no_content
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    # DELETE /users/1
    # DELETE /users/1.json
    def destroy
      @user = User.find_by_login!(params[:id])
      @user.destroy

      head :no_content
    end
  end
end
