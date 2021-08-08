defmodule WhsApp.Operation do
  import Ecto.Query, warn: false

  alias WhsApp.Repo
  alias WhsApp.Operator.Operations

  def get_all_operations(query \\ Operations) do
    Repo.all(query)
  end

  def add_operation(operation_params) do
    %Operations{}
    |> Operations.changeset(operation_params)
    |> Repo.insert()
  end
end
