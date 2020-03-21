# frozen_string_literal: true

class OptionsHelper
  include ActionView::Helpers::FormOptionsHelper

  attr_reader :collection, :params, :query, :model, :method
  def initialize(collection, params, query, model = nil, method = nil)
    @collection = collection
    @params     = params
    @query      = query
    @model      = model
    @method     = method
  end

  # Wraps static collection in options, selects value if provided in query
  def self.wrap(collection, params, query)
    new(collection, params, query).wrap_options
  end

  # Fetches selected value from model and returns it in options
  def self.fetch(model, method, params, query)
    new(nil, params, query, model, method).fetch_options
  end

  def wrap_options
    return collection_without_selection unless current_value

    collection_with_selection
  end

  def fetch_options
    if current_value
      @collection = model.where(id: current_value).map { |i| [i.send(method), i.id] }
      collection_with_selection
    else
      @collection = []
      collection_without_selection
    end
  end

  def collection_without_selection
    options_for_select(collection)
  end

  def collection_with_selection
    options_for_select(collection, current_value)
  end

  def current_value
    return unless params[:q]
    return unless params[:q][query.to_sym]

    params[:q][query.to_sym]
  end
end
