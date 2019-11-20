defmodule DBux.Auth.External do
  require Logger
  use Connection

  @behaviour DBux.Auth

  @debug !is_nil(System.get_env("DBUX_DEBUG"))

  def start_link(_parent, options) do
    if @debug, do: Logger.debug("[DBux.Auth.External #{inspect(self())}] Start link")
    Connection.start_link(__MODULE__, options)
  end


  @doc false
  def init(_options) do
    if @debug, do: Logger.debug("[DBux.Auth.External #{inspect(self())}] Init")
    {:ok, %{}}
  end


  def do_handshake(auth_proc, transport_mod, transport_proc) do
    Connection.call(auth_proc, {:handshake, {transport_mod, transport_proc}})
  end


  def handle_call({:handshake, {transport_mod, transport_proc}}, _sender, state) do
    if @debug, do: Logger.debug("[DBux.Auth.External #{inspect(self())}] Handle call: Handshake")

    uid = System.cmd("id", ["-u"]) |> elem(0) |> String.trim |> Base.encode16

    case transport_mod.do_send(transport_proc, "\0AUTH EXTERNAL #{uid}\r\n") do
      :ok ->
        {:reply, :ok, state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end
end
