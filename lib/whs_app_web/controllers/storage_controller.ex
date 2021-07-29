defmodule WhsAppWeb.StorageController do
  use WhsAppWeb, :controller

  alias WhsApp.Operator.Storage
  alias WhsApp.Operator

  def index(conn, _) do
    storage = Operator.get_all_goods()
    render(conn, "index.html", storage: storage)
  end
end
