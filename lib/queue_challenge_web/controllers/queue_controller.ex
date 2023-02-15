defmodule QueueChallengeWeb.QueueController do
  require Logger
  use QueueChallengeWeb, :controller

  @registry :queue_registry

  @spec index(Plug.Conn.t(), map) :: Plug.Conn.t()
  def index(conn, %{"queue" => queue, "message" => message}) do
    case Registry.lookup(@registry, queue) do
      [] ->
        Logger.debug("starting new queue")
        QueueChallenge.QueueSupervisor.start_child(queue, message)
      _ ->
        QueueChallenge.QueueService.add_message(queue, message)
    end

    Plug.Conn.send_resp(conn, 200, "success")
  end
end
