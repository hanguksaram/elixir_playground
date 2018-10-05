defmodule Test.BearController do

  alias Test.Wildthings
  alias Test.Bear

  @templates_path Path.expand("../../templates", __DIR__)

  defp render(conv, template, bindings \\ []) do
    content =
      @templates_path
      |> Path.join(template)
      |> EEx.eval_file(bindings)

    %{ conv | status: 200, resp_body: content }
  end

  # defp bear_item(bear) do
  #   "<li>#{bear.name} - #{bear.type}</li>"
  # end
  def index(conv) do
    bears =
      Wildthings.list_bears()
      |> Enum.sort(fn(b1, b2) -> Bear.order_asc_by_name(b1, b2) end)

    render(conv, "index.eex", bears: bears)
  end
  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    render(conv, "show.eex", bear: bear)
  end
  def create(conv, params) do
    %{ conv | status: 201,
  resp_body: "Created a #{params["type"]} kek"}
  end
end
