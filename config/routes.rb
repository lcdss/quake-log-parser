Rails.application.routes.draw do
  get '/', to: 'home#index'
  match '/report', to: 'home#report', via: [:get, :post]
end
