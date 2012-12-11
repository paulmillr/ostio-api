module V1
  class UsersController < ApplicationController
    before_filter :check_sign_in, except: [:index, :show]

    def to_json(thing)
      incl = thing.type == 'User' ? :organizations : :owners
      thing.to_json(include: [:organizations, :owners])
    end

    def index
      @users = User.limit(24)
      render json: @users
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
      @user = current_user

      keys = User.accessible_attributes.to_a.reject(&:empty?)
      attributes = {}
      keys.each do |key|
        attributes[key] = params[key] if params.has_key?(key)
      end

      if @user.update_attributes(attributes)
        head :no_content
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    # DELETE /users/1
    # DELETE /users/1.json
    def destroy
      @user = current_user
      @user.destroy

      head :no_content
    end
  end
end
