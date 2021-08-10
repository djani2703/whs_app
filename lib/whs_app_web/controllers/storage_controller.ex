defmodule WhsAppWeb.StorageController do
  use WhsAppWeb, :controller

  alias WhsApp.Operator.Storage
  alias WhsApp.Operator

  @goods_added_msg "New good added successfully!"
  @goods_blocked_msg "Product blocked successfully!"
  @goods_have_in_stock_msg "Cannot block product: have in stock.."
  @goods_already_blocked_msg "Cannot block product: already blocked.."
  @goods_put_msg "Products added successfully!"
  @goods_take_msg "Products removed successfully!"
  @goods_reserved_msg "Products reserved successfully!"
  @goods_not_updated_msg "Product not updated.."
  @invalid_request_data "Invalid changing amount request data.."
  @invalid_input_data "Enter value for amount greater than 0."
  @a_lot_to_put "Large value to put products.."
  @a_lot_to_take "Large value to take products.."
  @a_lot_to_reserve "Large value to reserve products.."
  @a_lot_to_unreserve "Large value to unreserve products.."

  # WEB:
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
    case Operator.add_new_good(params) do
      {:ok, %Storage{:id => id} = goods} ->
        Operator.add_operation_note(goods, 0, "new")
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
    case Operator.get_goods!(id) do
      {:ok, %Storage{:units_in_stock => 0, :active => true} = goods} ->
        update(conn, goods, %{:active => false}, @goods_blocked_msg, 0, "block")

      {:ok, %Storage{:active => true}} ->
        broadcast_msg!(conn, @goods_have_in_stock_msg, :all_products)

      {:ok, %Storage{:active => false}} ->
        broadcast_msg!(conn, @goods_already_blocked_msg, :all_products)

      {:error, msg} ->
        broadcast_msg!(conn, msg, :all_products)
    end
  end

  def block_product(conn, %{"id" => id, "storage" => params}) do
    {:ok, goods} = Operator.get_goods!(id)
    update(conn, goods, params, @goods_blocked_msg, 0, "block")
  end

  def can_add_products?(conn, params) do
    product_exists?("add", conn, params)
  end

  def can_remove_products?(conn, params) do
    product_exists?("remove", conn, params)
  end

  def can_reserve_products?(conn, params) do
    product_exists?("reserve", conn, params)
  end

  defp product_exists?(mark, conn, %{"id" => id}) do
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

  def add_products(conn, _) do
    broadcast_msg!(conn, @invalid_request_data, :all_products)
  end

  def remove_products(conn, %{"id" => id, "storage" => %{"remove_amount" => rem}}) do
    valid_input_amount_data("remove", conn, id, rem)
  end

  def remove_products(conn, _) do
    broadcast_msg!(conn, @invalid_request_data, :all_products)
  end

  def reserve_products(conn, %{"id" => id, "storage" => %{"reserve_amount" => rsv}}) do
    valid_input_amount_data("reserve", conn, id, rsv)
  end

  def reserve_products(conn, _) do
    broadcast_msg!(conn, @invalid_request_data, :all_products)
  end

  defp valid_input_amount_data(mark, conn, id, data) do
    case Integer.parse(data) do
      {add, _} when add > 0 and mark == "add" ->
        put_products(conn, id, add)

      {rem, _} when rem > 0 and mark == "remove" ->
        take_products(conn, id, rem)

      {rsv, _} when rsv > 0 and mark == "reserve" ->
        save_products(conn, id, rsv)

      _ ->
        broadcast_msg!(conn, @invalid_input_data, :all_products)
    end
  end

  defp put_products(conn, id, add) do
    {:ok, %{:units_in_stock => in_stock, :reserved => rsvd} = goods} = Operator.get_goods!(id)

    case in_stock + rsvd + add < 100_000_000 do
      true ->
        params = %{:units_in_stock => in_stock + add, :active => true}
        update(conn, goods, params, @goods_put_msg, add, "add")

      _ ->
        broadcast_msg!(conn, @a_lot_to_put, :all_products)
    end
  end

  defp take_products(conn, id, rem) do
    {:ok, %{:units_in_stock => in_stock} = goods} = Operator.get_goods!(id)

    case in_stock - rem >= 0 do
      true ->
        params = %{:units_in_stock => in_stock - rem}
        update(conn, goods, params, @goods_take_msg, rem, "remove")

      _ ->
        broadcast_msg!(conn, @a_lot_to_take, :all_products)
    end
  end

  defp save_products(conn, id, rsv) do
    {:ok, %{:units_in_stock => in_stock, :reserved => rsvd} = goods} = Operator.get_goods!(id)

    case in_stock - rsv >= 0 and rsvd + rsv < 100_000_000 do
      true ->
        params = %{:units_in_stock => in_stock - rsv, :reserved => rsvd + rsv}
        update(conn, goods, params, @goods_reserved_msg, rsv, "reserve")

      _ ->
        broadcast_msg!(conn, @a_lot_to_reserve, :all_products)
    end
  end

  defp update(conn, goods, params, msg, amount, mark) do
    case Operator.update_goods(goods, params) do
      {:ok, goods} ->
        Operator.add_operation_note(goods, amount, mark)
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

  # API's:
  def api_balance_products(conn, _) do
    goods = Operator.get_balance_goods()
    render(conn, "balance_all.json", goods: goods)
  end

  def api_balance_product(conn, params) do
    api_product_exists?("balance", conn, params)
  end

  def api_reserve_product(conn, params) do
    api_product_exists?("reserve", conn, params)
  end

  def api_unreserve_product(conn, params) do
    api_product_exists?("unreserve", conn, params)
  end

  defp api_product_exists?(mark, conn, %{"id" => id} = params) do
    case Operator.get_goods!(id) do
      {:ok, goods} when mark == "balance" ->
        render(conn, "balance_one.json", goods: goods)

      {:ok, _} when mark == "reserve" ->
        api_reserve_products(conn, params)

      {:ok, _} when mark == "unreserve" ->
        api_unreserve_products(conn, params)

      {:error, msg} ->
        render(conn, "error.json", msg: msg)
    end
  end

  defp api_reserve_products(conn, %{"id" => id, "amount" => amount}) do
    api_valid_input_amount_data("reserve", conn, id, amount)
  end

  defp api_unreserve_products(conn, %{"id" => id, "amount" => amount}) do
    api_valid_input_amount_data("unreserve", conn, id, amount)
  end

  defp api_valid_input_amount_data(mark, conn, id, data) do
    case Integer.parse(data) do
      {rsv, _} when rsv > 0 and mark == "reserve" ->
        api_save_products(conn, id, rsv)

      {ursv, _} when ursv > 0 and mark == "unreserve" ->
        api_extract_products(conn, id, ursv)

      _ ->
        render(conn, "error.json", msg: @invalid_input_data)
    end
  end

  defp api_save_products(conn, id, rsv) do
    {:ok, %{:units_in_stock => in_stock, :reserved => rsvd} = goods} = Operator.get_goods!(id)

    case in_stock - rsv >= 0 and rsvd + rsv < 100_000_000 do
      true ->
        params = %{:units_in_stock => in_stock - rsv, :reserved => rsvd + rsv}
        api_update(conn, goods, params, rsv, "reserve")

      _ ->
        render(conn, "error.json", msg: @a_lot_to_reserve)
    end
  end

  defp api_extract_products(conn, id, ursv) do
    {:ok, %{:units_in_stock => in_stock, :reserved => rsvd} = goods} = Operator.get_goods!(id)

    case in_stock + ursv < 100_000_000 and rsvd - ursv >= 0 do
      true ->
        params = %{:units_in_stock => in_stock + ursv, :reserved => rsvd - ursv}
        api_update(conn, goods, params, ursv, "unreserve")

      _ ->
        render(conn, "error.json", msg: @a_lot_to_unreserve)
    end
  end

  defp api_update(conn, goods, params, amount, mark) do
    case Operator.update_goods(goods, params) do
      {:ok, goods} ->
        Operator.add_operation_note(goods, amount, mark)
        render(conn, "reserve.json", goods: goods)

      {:error, _} ->
        render(conn, "error.json", msg: @goods_not_updated_msg)
    end
  end
end
