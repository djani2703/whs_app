defmodule WhsAppWeb.OperationsController do
  use WhsAppWeb, :controller

  alias WhsApp.Operation

  def all_operations(conn, _) do
    operations = Operation.get_all_operations()
    render(conn, "index.html", operations: operations)
  end
end
