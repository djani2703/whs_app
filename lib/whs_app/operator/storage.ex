defmodule WhsApp.Operator.Storage do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "storage" do
    field :title, :string, size: 50, null: false
    field :units_in_stock, :integer, default: 0, null: false
    field :reserved, :integer, default: 0, null: false
    field :active, :boolean, default: true, null: false

    timestamps()
  end

  def changeset(storage, attrs) do
    storage
    |> cast(attrs, [:title, :units_in_stock, :reserved, :active])
    |> validate_required([:title, :units_in_stock, :reserved, :active])
  end
end
