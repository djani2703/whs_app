defmodule WhsApp.Operator.Storage do
  use Ecto.Schema
  import Ecto.Changeset

  alias WhsApp.Operator.Operations

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "storage" do
    field :title, :string, size: 50, null: false
    field :units_in_stock, :integer, default: 0, null: false
    field :reserved, :integer, default: 0, null: false
    field :active, :boolean, default: true, null: false
    has_many :operations, Operations, foreign_key: :goods_id

    timestamps()
  end

  def changeset(storage, attrs) do
    storage
    |> cast(attrs, [:title, :units_in_stock, :reserved, :active])
    |> validate_required([:title, :units_in_stock, :reserved, :active])
    |> unique_constraint(:title, name: :index_for_unique_title)
    |> validate_number(:units_in_stock, greater_than_or_equal_to: 0, less_than: 100_000_000)
  end
end
