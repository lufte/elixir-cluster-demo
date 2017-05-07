defmodule Client do

  def receive do
    receive do
      {function, args, caller} ->
        IO.puts "#{Node.self} received a function and #{length(args)} args"
        start = DateTime.to_unix(DateTime.utc_now)

        # Execute "function" for each arg in "args", and put all "arg: result" tuples in a map
        results = Enum.reduce args, %{}, fn arg, acc -> Map.put(acc, arg, function.(arg)) end

        duration = DateTime.to_unix(DateTime.utc_now) - start
        IO.puts "#{Node.self} took #{duration} seconds to execute"

        # Respond to the caller with the results map
        send caller, results
    end
  end

end


defmodule Maths do

  def fibonacci 0 do
    1
  end

  def fibonacci 1 do
    1
  end

  def fibonacci(n) when n > 0 do
    fibonacci(n - 1) + fibonacci(n - 2)
  end

end