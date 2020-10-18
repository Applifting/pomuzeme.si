class Tableless
  include ActiveModel::Validations
  include ActiveModel::Model
  extend ActiveModel::Callbacks

  define_model_callbacks :create, :update, :validation
end