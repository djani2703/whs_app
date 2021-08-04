defmodule WhsAppWeb.StorageController do
  use WhsAppWeb, :controller

  alias WhsApp.Operator.Storage
  alias WhsApp.Operator

  @goods_added_msg "New good added successfully!"
  @goods_blocked_msg "Product blocked successfully!"

  def all_products(conn, _) do
    goods = Operator.get_all_goods()
    render(conn, "index.html", goods: goods)
  end

  def new_product(conn, _) do
    changeset = Operator.change_goods(%Storage{})
    render(conn, "actions.html", changeset: changeset, mark: "new")
  end

  def create_product(conn, %{"storage" => params}) do
    case Operator.add_new_good(params) do
      {:ok, %Storage{:id => id}} ->
        broadcast_msg!(conn, @goods_added_msg, :show_product, id)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset, mark: "new")
    end
  end

  def show_product(conn, %{"id" => id}) do
    case Operator.get_goods!(id) do
      {:ok, goods} ->
        render(conn, "show.html", goods: goods)

      {:error, msg} ->
        broadcast_msg!(conn, msg, :all_products)
    end
  end

  def can_block_product?(conn, %{"id" => id}) do
    case Operator.can_block_goods?(id) do
      {true, goods} ->
        update(conn, goods, %{:active => false}, @goods_blocked_msg, "block")

      {false, msg} ->
        broadcast_msg!(conn, msg, :all_products)
    end
  end

  def block_product(conn, %{"id" => id, "storage" => params}) do
    {:ok, goods} = Operator.get_goods!(id)
    update(conn, goods, params, @goods_blocked_msg, "block")
  end

  defp update(conn, goods, params, msg, mark) do
    case Operator.update_goods(goods, params) do
      {:ok, goods} ->
        broadcast_msg!(conn, msg, :show_product, goods)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", goods: goods, changeset: changeset, mark: mark)
    end
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
