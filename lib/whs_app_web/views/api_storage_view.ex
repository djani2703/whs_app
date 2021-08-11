defmodule WhsAppWeb.ApiStorageView do
  use WhsAppWeb, :view

  alias WhsAppWeb.ApiStorageView

  def render("balance_all.json", %{goods: goods}) do
    %{ok: render_many(goods, ApiStorageView, "all_info.json")}
  end

  def render("balance_one.json", %{goods: goods}) do
    %{ok: render_one(goods, ApiStorageView, "balance_info.json")}
  end

  def render("reserve.json", %{goods: goods}) do
    %{ok: render_one(goods, ApiStorageView, "balance_info.json")}
  end

  def render("all_info.json", %{api_storage: storage}) do
    %{
      id: storage.id,
      title: storage.title,
      units_in_stock: storage.units_in_stock,
      reserved: storage.reserved,
      active: storage.active,
      inserted_at: storage.inserted_at,
      updated_at: storage.updated_at
    }
  end

  def render("balance_info.json", %{api_storage: storage}) do
    %{
      title: storage.title,
      units_in_stock: storage.units_in_stock,
      reserved: storage.reserved
    }
  end

  def render("error.json", %{msg: msg}), do: %{error: msg}
end
