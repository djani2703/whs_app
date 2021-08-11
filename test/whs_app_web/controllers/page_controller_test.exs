defmodule WhsAppWeb.PageControllerTest do
  use WhsAppWeb.ConnCase

  test "main page test", %{conn: conn} do
    conn = get(conn, Routes.page_path(conn, :main_page))
    assert html_response(conn, 200) =~ "Welcome to WHS"
  end
end
