defmodule WhsAppWeb.StorageView do
  use WhsAppWeb, :view

  alias WhsAppWeb.StorageView

  def render("balance_all.json", %{goods: goods}) do
    %{goods: render_many(goods, StorageView, "all_info.json")}
  end

  def render("balance_one.json", %{goods: goods}) do
    %{goods: render_one(goods, StorageView, "balance_info.json")}
  end

  def render("all_info.json", %{storage: storage}) do
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

  def render("balance_info.json", %{storage: storage}) do
    %{
      id: storage.id,
      title: storage.title,
      units_in_stock: storage.units_in_stock,
      reserved: storage.reserved
    }
  end

  def render("error.json", %{msg: msg}), do: %{goods: msg}
end
