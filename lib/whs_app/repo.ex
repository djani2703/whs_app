defmodule WhsApp.Repo do
  use Ecto.Repo,
    otp_app: :whs_app,
    adapter: Ecto.Adapters.Postgres
end
