class OrdersController < ApplicationController
  before_filter :authenticate_user!
  # before_action :set_order, only: [:show]

  def new
  end

  def create
    @order = current_user.create_order(order_params)
    @order.items.create(item_params)
    purchase_loc = Location.create(purchase_location_params)
    delivery_loc = Location.create( longitude: delivery_location_params[:longitude_to],
                                    latitude:  delivery_location_params[:latitude_to],
                                    address:   delivery_location_params[:address_to])
    trip = @order.create_trip(start_location_id: purchase_loc.id, end_location_id: delivery_loc.id)
    redirect_to pay @order
  end

  def show
    @order = Order.find(params[:id])
  end

  def pay order
    values = {
        business: "adrian_sutanahadi-facilitator@hotmail.com",
        cmd: "_xclick",
        upload: 1,
        return: "#{ENV["DOMAIN_NAME"]}/orders/#{order.id}",
        invoice: order.id,
        amount: order.items.first.estimated_price + order.tips,
        item_name: order.items.first.name,
        quantity: '1',
        notify_url: "#{ENV["DOMAIN_NAME"]}/hook"
    }
    "https://www.sandbox.paypal.com/cgi-bin/webscr?" + values.to_query 
  end

  protect_from_forgery except: [:hook]
  def hook
    params.permit! # Permit all Paypal input params
    status = params[:payment_status]
    if status == "Completed"
      @order = Order.find params[:invoice]
      @order.update_attributes status: 'Unassigned'
      @order.user.account.balance += params[:mc_gross]
      transaction = Transaction.create type: 'Credit', paymentID: params[:txn_id], account_id: @order.user.account.id
    end
    render nothing: true
  end

  private
    # # Use callbacks to share common setup or constraints between actions.
    # def set_order
    #   @order = Order.find(current_customer.id)
    # end

    def order_params
      params.require(:order).permit(:tips)
    end

    def item_params
      params.require(:item).permit(:name, :quantity, :estimated_price)
    end

    def purchase_location_params
      params.require(:location).permit(:longitude, :latitude, :address)
    end

    def delivery_location_params
      params.require(:location).permit(:longitude_to, :latitude_to, :address_to)
    end
end
