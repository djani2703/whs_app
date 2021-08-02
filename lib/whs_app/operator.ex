defmodule WhsApp.Operator do
  import Ecto.Query, warn: false
  alias WhsApp.Repo

  alias WhsApp.Operator.Storage

  @goods_not_found_msg "Product not found.."

  def get_all_goods() do
    Repo.all(Storage)
  end

  def add_new_good(storage_params) do
    %Storage{}
    |> Storage.changeset(storage_params)
    |> Repo.insert()
  end

  def get_goods!(id) do
    try do
      {:ok, Repo.get!(Storage, id)}
    rescue
      [Ecto.Query.CastError, Ecto.NoResultsError] ->
        {:error, @goods_not_found_msg}
    end
  end

  def change_goods(%Storage{} = goods, params \\ %{}) do
    Storage.changeset(goods, params)
  end
end
