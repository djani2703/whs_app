defmodule WhsAppWeb.StorageController do
  use WhsAppWeb, :controller

  alias WhsApp.Operator.Storage
  alias WhsApp.Operator

  def index(conn, _) do
    goods = Operator.get_all_goods()
    render(conn, "index.html", goods: goods)
  end
end
