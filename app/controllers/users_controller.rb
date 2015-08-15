class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    redirect_to new_user_session_path if !user_signed_in?
    @user = current_user
  end

  def show
    @user = User.find(params[:id])
    unless @user == current_user
      redirect_to :back, :alert => "Access denied."
    end
  end

  def account
    @account = Account.where(user_id: current_user.id).first
    if @account == nil
      @account = Account.create(balance: 0, user_id: current_user.id)
    end
  end

end
