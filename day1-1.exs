{:ok, input} = File.read("inputs/day1.txt")

defmodule AOC do
	def fuel_cost(mass) do
		((mass / 3) |> :math.floor) - 2
	end
end

result = input |> String.split
|> Enum.map(&String.to_integer/1)
|> Enum.map(&AOC.fuel_cost/1)
|> Enum.sum

IO.puts result
