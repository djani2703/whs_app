defmodule WhsApp.Operation do
  import Ecto.Query, warn: false

  alias WhsApp.Repo
  alias WhsApp.Operator.Operations

  def get_all_operations() do
    Repo.all(
      from o in Operations,
        order_by: [desc: o.inserted_at]
    )
  end

  def add_operation(operation_params) do
    %Operations{}
    |> Operations.changeset(operation_params)
    |> Repo.insert()
  end
end
