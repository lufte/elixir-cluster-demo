defmodule Cluster do

  def get_hosts do
    File.read!("hosts")                                   # Read the file
    |> String.split("\n")                                 # Split it in lines
    |> Enum.filter(fn elem -> elem != "" end)             # Filter empty lines
    |> Enum.map(&String.to_atom/1)                        # Convert strings to atoms
    |> (fn list -> [Node.self | list] end).()             # Add our node to the list
  end

  def remote_call node, function, args do
    pid = Node.spawn_link node, &Client.receive/0         # Spawn the receive function on the node
    send pid, {function, args, self()}                    # Send the function and args to the node
  end


  def run do

    args = [35, 39, 37, 34, 30, 38, 36, 40]
    nodes = get_hosts()
    batch = round Float.ceil(length(args) / length(nodes))

    # Build a map with each node as key and its list of arguments as value
    args_for_nodes = Enum.zip(nodes, Enum.chunk(args, batch, batch, []))

    # Get the current time
    start = DateTime.to_unix(DateTime.utc_now)

    # Execute the "remote_call" for each node, which will spawn the "receive" function on them
    Enum.each(args_for_nodes, fn {host, args} -> remote_call(host, &Maths.fibonacci/1, args) end)

    # Wait for as many messages as nodes we used
    results = Enum.reduce(args_for_nodes, %{}, fn _, acc ->
      receive do
        result -> Map.merge(acc, result)
      end
    end)

    duration = DateTime.to_unix(DateTime.utc_now) - start
    IO.puts "===================================="
    IO.inspect results
    IO.puts "Finished in #{duration} seconds"
  end

end
