
require 'braintree'

Braintree::Configuration.environment = :sandbox
Braintree::Configuration.merchant_id = 'ffdqc9fyffn7yn2j'
Braintree::Configuration.public_key = 'qj65nndbnn6qyjkp'
Braintree::Configuration.private_key = 'a3de3bb7dddf68ed3c33f4eb6d9579ca'

class OrdersController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_order, only: [:show, :deliver, :confirm]

  def index
    @orders = Order.unassigned.all
  end

  def search
    current_loc = Location.create(purchase_location_params)
    destination = Location.create( longitude: delivery_location_params[:longitude_to],
                                    latitude:  delivery_location_params[:latitude_to],
                                    address:   delivery_location_params[:address_to])
    delivery_trip = Trip.new(start_location_id: current_loc.id, end_location_id: destination.id)

    @orders = Order.unassigned.all.sort do |x, y|
                x_trip_distance = x.trip.distance(delivery_trip)
                y_trip_distance = y.trip.distance(delivery_trip)
                y_trip_distance <=> x_trip_distance
              end

    render :index
  end

  def new
    @client_token = Braintree::ClientToken.generate
  end

  def create
    @order = current_user.orders.create(order_params)
    @order.items.create(item_params)
    purchase_loc = Location.create(purchase_location_params)
    delivery_loc = Location.create( longitude: delivery_location_params[:longitude_to],
                                    latitude:  delivery_location_params[:latitude_to],
                                    address:   delivery_location_params[:address_to])
    trip = @order.create_trip(start_location_id: purchase_loc.id, end_location_id: delivery_loc.id)

    result = Braintree::Transaction.sale(
      amount: @order.items.first.estimated_price + @order.tips,
      payment_method_nonce: params[:payment_method_nonce]
    )

    if result.success?
      @transaction = result.transaction
      @order.update_attributes status: 'unassigned'
      @order.user.account.balance += @order.items.first.estimated_price + @order.tips
      @order.user.account.save
      `say Payment succeed`
      # `say #{@transaction}`
      # redirect_to user_orders_path
    else
      "Payment failed"
    end

    redirect_to user_orders_path

  end

  def show
  end

  def confirm
    @order.status = "completed"
    @order.save
    @order.user.account.balance -= @order.items.first.estimated_price + @order.tips
    @order.user.account.save
    @order.deliverer.account.balance += @order.items.first.estimated_price + @order.tips
    @order.deliverer.account.save

    redirect_to user_orders_path, notice: 'Order has been successfully completed.'
  end

  # GET /orders/:id/deliver
  def deliver
    @order.deliverer = current_user
    @order.status = 'assigned'
    @order.save
    redirect_to user_deliveries_path, notice: 'Order was successfully assigned.'
  end


  # def pay order
  #   values = {
  #       business: "adrian_sutanahadi-facilitator@hotmail.com",
  #       cmd: "_xclick",
  #       upload: 1,
  #       return: "#{ENV["DOMAIN_NAME"]}/orders/#{order.id}",
  #       invoice: order.id,
  #       amount: order.items.first.estimated_price + order.tips,
  #       item_name: order.items.first.name,
  #       quantity: '1',
  #       notify_url: "#{ENV["DOMAIN_NAME"]}/hook"
  #   }
  #   "https://www.sandbox.paypal.com/cgi-bin/webscr?" + values.to_query 
  # end

  def confirm_delivery order
    order.status = 'Completed'
    order.user.account.balance -= order.items.first.estimated_price + order.tips
    order.deliverer.account.balance += order.items.first.estimated_price + order.tips
    order.save
    redirect_to user_orders_path, notice: 'Order was successfully completed'
  end

  # def

  protect_from_forgery except: [:hook]
  def hook
    params.permit! # Permit all Paypal input params
    status = params[:payment_status]
    if status == "Completed"
      @order = Order.find params[:invoice]
      @order.update_attributes status: 'unassigned'
      @order.user.account.balance += params[:mc_gross]
      transaction = Transaction.create type: 'Credit', paymentID: params[:txn_id], account_id: @order.user.account.id
    end
    render nothing: true
  end

  private
    # # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

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
