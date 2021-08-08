defmodule WhsApp.Operator.Operations do
  use Ecto.Schema
  import Ecto.Changeset

  schema "operations" do
    field :title, :string, null: false
    field :operation, :string, null: false
    field :amount, :integer, null: false
    field :goods_id, :binary_id, null: false

    timestamps()
  end

  def changeset(storage, attrs) do
    storage
    |> cast(attrs, [:title, :operation, :amount, :goods_id])
    |> validate_required([:title, :operation, :amount, :goods_id])
  end
end
