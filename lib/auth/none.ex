defmodule DBux.Auth.None do
  require Logger
  use Connection

  @behaviour DBux.Auth

  @debug !is_nil(System.get_env("DBUX_DEBUG"))

  def start_link(_parent, options) do
    if @debug, do: Logger.debug("[DBux.Auth.None #{inspect(self())}] Start link")
    Connection.start_link(__MODULE__, options)
  end


  @doc false
  def init(_options) do
    if @debug, do: Logger.debug("[DBux.Auth.None #{inspect(self())}] Init")
    {:ok, %{}}
  end


  def do_handshake(auth_proc, transport_mod, transport_proc) do
    Connection.call(auth_proc, {:handshake, {transport_mod, transport_proc}})
  end


  def handle_call({:handshake, {transport_mod, transport_proc}}, _sender, state) do
    if @debug, do: Logger.debug("[DBux.Auth.None #{inspect(self())}] Handle call: Handshake")
    
    send(transport_proc, {:tcp, nil, "OK (SKIP AUTH)"})

    {:reply, :ok, state}
  end
end
