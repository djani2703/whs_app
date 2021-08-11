defmodule WhsApp.Helpers.AppHelper do

  alias WhsApp.Operator
  alias WhsApp.Operator.Storage

  @goods_added_msg "New good added successfully!"
  @goods_blocked_msg "Product blocked successfully!"
  @goods_have_in_stock_msg "Cannot block product: have in stock.."
  @goods_already_blocked_msg "Cannot block product: already blocked.."
  @goods_put_msg "Products added successfully!"
  @goods_take_msg "Products removed successfully!"
  @goods_reserved_msg "Products reserved successfully!"
  @goods_not_found_msg "Product not found.."
  @goods_not_updated_msg "Product not updated.."
  @invalid_request_data "Invalid changing amount request data.."
  @invalid_input_data "Enter value for amount greater than 0."
  @a_lot_to_put "Large value to put products.."
  @a_lot_to_take "Large value to take products.."
  @a_lot_to_reserve "Large value to reserve products.."
  @a_lot_to_unreserve "Large value to unreserve products.."


  def run_creating_product(params) do
    case Operator.add_new_good(params) do
      {:ok, %Storage{:units_in_stock => in_stock} = goods} ->
        Operator.add_operation_note(goods, in_stock, "new")
        {:ok, goods, @goods_added_msg}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  def run_blocking_product(id) do
    with {:ok, goods} <- can_blocking_product?(id),
         {:ok, goods} <- update(goods, %{:active => false}, 0, "block") do
      {:ok, goods, @goods_blocked_msg}
    end
  end

  def can_blocking_product?(id) do
    case product_exists?(id) do
      {:ok, %Storage{:units_in_stock => 0, :active => true} = goods} ->
        {:ok, goods}

      {:ok, %Storage{:active => true}} ->
        {:error, @goods_have_in_stock_msg}

      {:ok, %Storage{:active => false}} ->
        {:error, @goods_already_blocked_msg}

      {:error, msg} ->
        {:error, msg}
    end
  end

  def run_adding_product(id, data) do
    with {:ok, goods, amount} <- check_valid_request_params(id, data),
         {:ok, upd_params} <- put_products(goods, amount),
         {:ok, goods} <- update(goods, upd_params, amount, "add") do
      {:ok, goods, @goods_put_msg}
    end
  end

  def put_products(goods, add) do
    %{:units_in_stock => in_stock, :reserved => rsvd} = goods

    case in_stock + rsvd + add < 100_000_000 do
      true ->
        {:ok, %{:units_in_stock => in_stock + add, :active => true}}

      _ ->
        {:error, @a_lot_to_put}
    end
  end

  def run_removing_product(id, data) do
    with {:ok, goods, amount} <- check_valid_request_params(id, data),
         {:ok, upd_params} <- take_products(goods, amount),
         {:ok, goods} <- update(goods, upd_params, amount, "remove") do
      {:ok, goods, @goods_take_msg}
    end
  end

  def take_products(goods, rem) do
    %{:units_in_stock => in_stock} = goods

    case in_stock - rem >= 0 do
      true ->
        {:ok, %{:units_in_stock => in_stock - rem}}

      _ ->
        {:error, @a_lot_to_take}
    end
  end

  def run_reserving_product(id, data) do
    with {:ok, goods, amount} <- check_valid_request_params(id, data),
         {:ok, upd_params} <- save_products(goods, amount),
         {:ok, goods} <- update(goods, upd_params, amount, "reserve") do
      {:ok, goods, @goods_reserved_msg}
    end
  end

  def save_products(goods, rsv) do
    %{:units_in_stock => in_stock, :reserved => rsvd} = goods

    case in_stock - rsv >= 0 and rsvd + rsv < 100_000_000 do
      true ->
        {:ok, %{:units_in_stock => in_stock - rsv, :reserved => rsvd + rsv}}

      _ ->
        {:error, @a_lot_to_reserve}
    end
  end

  def run_unreserving_product(id, data) do
    with {:ok, goods, amount} <- check_valid_request_params(id, data),
         {:ok, upd_params} <- extract_products(goods, amount),
         {:ok, goods} <- update(goods, upd_params, amount, "unreserve") do
      {:ok, goods}
    end
  end

  def extract_products(goods, ursv) do
    %{:units_in_stock => in_stock, :reserved => rsvd} = goods

    case in_stock + ursv < 100_000_000 and rsvd - ursv >= 0 do
      true ->
        {:ok, %{:units_in_stock => in_stock + ursv, :reserved => rsvd - ursv}}

      _ ->
        {:error, @a_lot_to_unreserve}
    end
  end

  def check_valid_request_params(id, amount) do
    with {:ok, goods} <- product_exists?(id),
         {:ok, amount} <- valid_input_amount_data(amount) do
      {:ok, goods, amount}
    end
  end

  def product_exists?(id) do
    case Operator.get_goods!(id) do
      {:ok, goods} ->
        {:ok, goods}

      {:error, _} ->
        {:error, @goods_not_found_msg}
    end
  end

  def valid_input_amount_data(data) do
    case Integer.parse(data) do
      {amount, _} when amount > 0 ->
        {:ok, amount}

      {_, _} ->
        {:error, @invalid_input_data}

      _ ->
        {:error, @invalid_request_data}
    end
  end

  def update(goods, params, amount, mark) do
    case Operator.update_goods(goods, params) do
      {:ok, goods} ->
        Operator.add_operation_note(goods, amount, mark)
        {:ok, goods}

      {:error, _} ->
        {:error, @goods_not_updated_msg}
    end
  end
end
