defmodule Test.Handler do

  alias Test.Conv
  alias Test.BearController
  alias Test.VideoCam


  @pages_path Path.expand("../../pages", __DIR__)

  import Test.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Test.Parser, only: [parse: 1]

  def handle(request)  do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  def route(%Conv{method: "POST", path: "/pledges"} = conv) do
    Test.PledgeController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    Test.PledgeController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/wildthings" } = conv) do
    %{ conv | status: 200, resp_body: "Bears, Lions, Tigers" }
  end

  def route(%Conv{ method: "GET", path: "/api/bears" } = conv) do
    Test.Api.BearController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/bears" } = conv) do
    BearController.index(conv)
  end
  def route(%Conv{ method: "GET", path: "/sensors"} = conv) do
    task = Task.async(fn -> Test.Tracker.get_location("bigfoot") end)
    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)



    where_is_bigfoot = Task.await(task)
    %{ conv | status: 200, resp_body: inspect {snapshots, where_is_bigfoot} }

  end

  def route(%Conv{ method: "GET", path: "/about" } = conv) do
      @pages_path
      |> Path.join("about.html")
      |> File.read
      |> handle_file(conv)
  end
  def route(%Conv{ method: "GET", path: "/bears/" <> id } = conv) do
    params = Map.put(conv.params, "id", id )
    BearController.show(conv, params)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end
  def route(%Conv{ path: path } = conv) do
    %{ conv | status: 404, resp_body: "No #{path} here!"}
  end

  def handle_file({:ok, content}, conv) do
    %{ conv | status: 200, resp_body: content }
  end

  def handle_file({:error, :enoent}, conv) do
    %{ conv | status: 404, resp_body: "File not found!"}
  end

  def handle_file({:error, reason}, conv) do
    %{ conv | status: 500, resp_body: "File error: #{reason}" }
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: #{conv.cont_type}
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
  end

end


