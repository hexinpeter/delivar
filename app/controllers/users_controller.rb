class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_user, only: [:show]

  def index
    redirect_to new_user_session_path if !user_signed_in?
    @user = current_user
  end

  def show

  end

  def deliveries
    @user = current_user
    @orders = @user.deliveries
  end

  private
    # # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
      unless @user == current_user
        redirect_to :index, :alert => "Access denied."
      end
    end
end
