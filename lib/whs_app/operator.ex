defmodule WhsApp.Operator do
  import Ecto.Query, warn: false
  alias WhsApp.Repo

  alias WhsApp.Operator.Storage

  def get_all_goods() do
    Repo.all(Storage)
  end
end
