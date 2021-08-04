defmodule WhsApp.Operator do
  import Ecto.Query, warn: false
  alias WhsApp.Repo

  alias WhsApp.Operator.Storage

  @goods_not_found_msg "Product not found.."
  @goods_have_in_stock_msg "Cannot block product: have in stock.."
  @goods_already_blocked_msg "Cannot block product: already blocked.."

  def get_all_goods() do
    Repo.all(Storage)
  end

  def add_new_good(storage_params) do
    %Storage{}
    |> Storage.changeset(storage_params)
    |> Repo.insert()
  end

  def change_goods(%Storage{} = goods, params \\ %{}) do
    Storage.changeset(goods, params)
  end

  def get_goods!(id) do
    try do
      {:ok, Repo.get!(Storage, id)}
    rescue
      [Ecto.Query.CastError, Ecto.NoResultsError] ->
        {:error, @goods_not_found_msg}
    end
  end

  def can_block_goods?(id) do
    case get_goods!(id) do
      {:ok, %Storage{:units_in_stock => 0, :active => true} = goods} ->
        {true, goods}

      {:ok, %Storage{:active => true}} ->
        {false, @goods_have_in_stock_msg}

      {:ok, %Storage{:active => false}} ->
        {false, @goods_already_blocked_msg}

      {:error, message} ->
        {false, message}
    end
  end

  def update_goods(%Storage{} = goods, attrs) do
    goods
    |> Storage.changeset(attrs)
    |> Repo.update()
  end
end
