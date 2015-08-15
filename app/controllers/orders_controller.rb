class OrdersController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_order, only: [:show, :deliver]

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
  end

  def create
    @order = current_user.create_order(order_params)
    @order.items.create(item_params)
    purchase_loc = Location.create(purchase_location_params)
    delivery_loc = Location.create( longitude: delivery_location_params[:longitude_to],
                                    latitude:  delivery_location_params[:latitude_to],
                                    address:   delivery_location_params[:address_to])
    trip = @order.create_trip(start_location_id: purchase_loc.id, end_location_id: delivery_loc.id)
    redirect_to @order, notice: 'Order was successfully created.'
  end

  def show
  end

  # GET /orders/:id/deliver
  def deliver
    @order.deliverer = current_user
    @order.status = 'assigned'
    @order.save
    redirect_to user_deliveries_path, notice: 'Order was successfully assigned.'
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
