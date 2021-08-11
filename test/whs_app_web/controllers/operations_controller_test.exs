defmodule WhsAppWeb.OperationsControllerTest do
  use WhsAppWeb.ConnCase

  test "all operator activities test", %{conn: conn} do
    conn = get(conn, Routes.operations_path(conn, :all_operations))
    assert html_response(conn, 200) =~ "All actions:"
  end
end
