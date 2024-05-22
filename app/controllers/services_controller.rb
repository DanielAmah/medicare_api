class ServicesController < ApplicationController
  skip_before_action :authenticate_request

  def index
    @services = Service.all
    render json: @services.map { |service| serialize_service(service) }
  end

  private

  def serialize_service(service)
    {
      id: service.id,
      name: service.name,
      description: service.description,
      date: service.created_at,
      price: service.price / 100,
      status: service.active
    }
  end
end

