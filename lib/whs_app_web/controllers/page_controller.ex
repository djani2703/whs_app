defmodule WhsAppWeb.PageController do
  use WhsAppWeb, :controller

  def main_page(conn, _params) do
    render(conn, "index.html")
  end
end
