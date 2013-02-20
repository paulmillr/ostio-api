module V1
  class HomeController < ApplicationController
    def index
      routes = Rails.application.routes.routes.select {|r| !r.name.nil?}
      serialized = routes.map do |route|
        {
          name: route.name,
          path: route.path.spec.to_s,
          segment_keys: route.segment_keys
        }
      end
      render json: serialized
    end
  end
end
