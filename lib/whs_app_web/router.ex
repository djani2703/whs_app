defmodule WhsAppWeb.Router do
  use WhsAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WhsAppWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/storage", StorageController, :all_products
    get "/storage/new", StorageController, :new_product
    get "/storage/on_balance", StorageController, :balance_products
    get "/storage/:id", StorageController, :show_product
    get "/storage/block/:id", StorageController, :can_block_product?
    get "/storage/add/:id", StorageController, :can_add_products?
    get "/storage/remove/:id", StorageController, :can_remove_products?
    get "/storage/reserve/:id", StorageController, :can_reserve_products?

    post "/storage", StorageController, :create_product
    put "/storage/:id/block", StorageController, :block_product
    put "/storage/:id/add", StorageController, :add_products
    put "/storage/:id/remove", StorageController, :remove_products
    put "/storage/:id/reserve", StorageController, :reserve_products
  end

  # Other scopes may use custom stacks.
  # scope "/api", WhsAppWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: WhsAppWeb.Telemetry
    end
  end
end
