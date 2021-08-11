defmodule WhsAppWeb.ApiStorageController do
  use WhsAppWeb, :controller

  alias WhsApp.Operator
  alias WhsApp.Helpers.AppHelper

  def api_balance_products(conn, _) do
    goods = Operator.get_balance_goods()
    render(conn, "balance_all.json", goods: goods)
  end

  def api_balance_product(conn, %{"id" => id}) do
    case AppHelper.product_exists?(id) do
      {:ok, goods} ->
        render(conn, "balance_one.json", goods: goods)

      {:error, msg} ->
        render(conn, "error.json", msg: msg)
    end
  end

  def api_reserve_product(conn, %{"id" => id, "amount" => data}) do
    case AppHelper.run_reserving_product(id, data) do
      {:ok, goods, _} ->
        render(conn, "reserve.json", goods: goods)

      {:error, msg} ->
        render(conn, "error.json", msg: msg)
    end
  end

  def api_unreserve_product(conn, %{"id" => id, "amount" => data}) do
    case AppHelper.run_unreserving_product(id, data) do
      {:ok, goods} ->
        render(conn, "reserve.json", goods: goods)

      {:error, msg} ->
        render(conn, "error.json", msg: msg)
    end
  end
end
