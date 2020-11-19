class Tableless
  include ActiveModel::Validations
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks
  extend ActiveModel::Callbacks

  define_model_callbacks :create, :update, :validation
end