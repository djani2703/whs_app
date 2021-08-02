defmodule WhsAppWeb.StorageController do
  use WhsAppWeb, :controller

  alias WhsApp.Operator.Storage
  alias WhsApp.Operator

  @goods_added_msg "New good added successfully!"

  def all_goods(conn, _) do
    goods = Operator.get_all_goods()
    render(conn, "index.html", goods: goods)
  end

  def new_product(conn, _) do
    changeset = Operator.change_goods(%Storage{})
    render(conn, "new.html", changeset: changeset, mark: "new")
  end

  def create_product(conn, %{"storage" => storage_params}) do
    case Operator.add_new_good(storage_params) do
      {:ok, %Storage{:id => id}} ->
        broadcast_msg!(conn, @goods_added_msg, :show_product, id)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, mark: "error_new")
    end
  end

  def show_product(conn, %{"id" => id}) do
    case Operator.get_goods!(id) do
      {:ok, goods} ->
        render(conn, "show.html", goods: goods)

      {:error, msg} ->
        broadcast_msg!(conn, msg, :all_goods)
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
