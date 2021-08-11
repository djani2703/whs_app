defmodule WhsAppWeb.StorageController do
  use WhsAppWeb, :controller

  alias WhsApp.Operator.Storage
  alias WhsApp.Operator
  alias WhsApp.Helpers.AppHelper

  def not_found(conn, _) do
    render(conn, "not_found.html", mark: "not_found")
  end

  def all_products(conn, _) do
    goods = Operator.get_all_goods()
    render(conn, "index.html", goods: goods, mark: "all")
  end

  def balance_products(conn, _) do
    goods = Operator.get_balance_goods()
    render(conn, "index.html", goods: goods, mark: "balance")
  end

  def new_product(conn, _) do
    changeset = Operator.change_goods(%Storage{})
    render(conn, "actions.html", changeset: changeset, mark: "new")
  end

  def create_product(conn, %{"storage" => params}) do
    case AppHelper.run_creating_product(params) do
      {:ok, goods, msg} ->
        broadcast_msg!(conn, msg, :show_product, goods)

      {:error, changeset} ->
        render(conn, "actions.html", changeset: changeset, mark: "new")
    end
  end

  def show_product(conn, %{"id" => id}) do
    case AppHelper.product_exists?(id) do
      {:ok, goods} ->
        render(conn, "show.html", goods: goods)

      {:error, msg} ->
        broadcast_msg!(conn, msg, :all_products)
    end
  end

  def can_block_product?(conn, %{"id" => id}) do
    case AppHelper.run_blocking_product(id) do
      {:ok, goods, msg} ->
        broadcast_msg!(conn, msg, :show_product, goods)

      {:error, msg} ->
        broadcast_msg!(conn, msg, :all_products)
    end
  end

  def can_add_products?(conn, %{"id" => id}) do
    case AppHelper.product_exists?(id) do
      {:ok, goods} ->
        changeset = Operator.change_goods(goods)
        render(conn, "actions.html", changeset: changeset, goods: goods, mark: "add")

      {:error, msg} ->
        broadcast_msg!(conn, msg, :all_products)
    end
  end

  def can_remove_products?(conn, %{"id" => id}) do
    case AppHelper.product_exists?(id) do
      {:ok, goods} ->
        changeset = Operator.change_goods(goods)
        render(conn, "actions.html", changeset: changeset, goods: goods, mark: "remove")

      {:error, msg} ->
        broadcast_msg!(conn, msg, :all_products)
    end
  end

  def can_reserve_products?(conn, %{"id" => id}) do
    case AppHelper.product_exists?(id) do
      {:ok, goods} ->
        changeset = Operator.change_goods(goods)
        render(conn, "actions.html", changeset: changeset, goods: goods, mark: "reserve")

      {:error, msg} ->
        broadcast_msg!(conn, msg, :all_products)
    end
  end

  def add_products(conn, %{"id" => id, "storage" => %{"add_amount" => add}}) do
    case AppHelper.run_adding_product(id, add) do
      {:ok, goods, msg} ->
        broadcast_msg!(conn, msg, :show_product, goods)

      {:error, msg} ->
        broadcast_msg!(conn, msg, :all_products)
    end
  end

  def add_products(conn, _) do
    broadcast_msg!(conn, "Invalid amount request data..", :all_products)
  end

  def remove_products(conn, %{"id" => id, "storage" => %{"remove_amount" => rem}}) do
    case AppHelper.run_removing_product(id, rem) do
      {:ok, goods, msg} ->
        broadcast_msg!(conn, msg, :show_product, goods)

      {:error, msg} ->
        broadcast_msg!(conn, msg, :all_products)
    end
  end

  def remove_products(conn, _) do
    broadcast_msg!(conn, "Invalid amount request data..", :all_products)
  end

  def reserve_products(conn, %{"id" => id, "storage" => %{"reserve_amount" => rsv}}) do
    case AppHelper.run_reserving_product(id, rsv) do
      {:ok, goods, msg} ->
        broadcast_msg!(conn, msg, :show_product, goods)

      {:error, msg} ->
        broadcast_msg!(conn, msg, :all_products)
    end
  end

  def reserve_products(conn, _) do
    broadcast_msg!(conn, "Invalid amount request data..", :all_products)
  end

  defp broadcast_msg!(conn, msg, route) do
    conn
    |> put_flash(:info, msg)
    |> redirect(to: Routes.storage_path(conn, route))
  end

  defp broadcast_msg!(conn, msg, route, data) do
    conn
    |> put_flash(:info, msg)
    |> redirect(to: Routes.storage_path(conn, route, data))
  end
end
