defmodule WhsAppWeb.StorageController do
  use WhsAppWeb, :controller

  alias WhsApp.Operator.Storage
  alias WhsApp.Operator

  @goods_added_msg "New good added successfully!"
  @goods_blocked_msg "Product blocked successfully!"
  @goods_put_msg "Products added successfully!"
  @invalid_request_data "Invalid changing amount request data.."
  @invalid_input_data "Enter value for amount greater than 0."
  @a_lot_to_put "Large amount value to put.."

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
        render(conn, "actions.html", changeset: changeset, mark: "new")
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

  def can_add_products?(conn, %{"id" => id}), do: start_change_amount("add", conn, id)

  defp start_change_amount(mark, conn, id) do
    case Operator.get_goods!(id) do
      {:ok, goods} ->
        changeset = Operator.change_goods(goods)
        render(conn, "actions.html", changeset: changeset, goods: goods, mark: mark)

      {:error, msg} ->
        broadcast_msg!(conn, msg, :all_products)
    end
  end

  def add_products(conn, %{"id" => id, "storage" => %{"add_amount" => add}}) do
    valid_input_amount_data("add", conn, id, add)
  end

  def add_products(conn, _), do: broadcast_msg!(conn, @invalid_request_data, :all_products)

  defp valid_input_amount_data(mark, conn, id, data) do
    case Integer.parse(data) do
      {add, _} when add > 0 and mark == "add" ->
        put_products(conn, id, add)

      _ ->
        broadcast_msg!(conn, @invalid_input_data, :all_products)
    end
  end

  defp put_products(conn, id, add) do
    {:ok, %{:units_in_stock => in_stock, :reserved => rsv} = goods} = Operator.get_goods!(id)

    case in_stock + rsv + add < 100_000_000 do
      true ->
        params = %{:units_in_stock => in_stock + add, :active => true}
        update(conn, goods, params, @goods_put_msg, "add")

      _ ->
        broadcast_msg!(conn, @a_lot_to_put, :all_products)
    end
  end

  defp update(conn, goods, params, msg, mark) do
    case Operator.update_goods(goods, params) do
      {:ok, goods} ->
        broadcast_msg!(conn, msg, :show_product, goods)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "actions.html", goods: goods, changeset: changeset, mark: mark)
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
