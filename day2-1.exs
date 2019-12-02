{:ok, input} = File.read("inputs/day2.txt")
tape = input |> String.trim |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple

defmodule AOC do
	def step(tape, pos) when elem(tape, pos) == 1 do
		tape |> put_elem(tape |> elem(pos+3),
			elem(tape, elem(tape, pos+1)) + elem(tape, elem(tape, pos+2))
		) |> step(pos+4)
	end

	def step(tape, pos) when elem(tape, pos) == 2 do
		tape |> put_elem(tape |> elem(pos+3),
			elem(tape, elem(tape, pos+1)) * elem(tape, elem(tape, pos+2))
		) |> step(pos+4)
	end

	def step(tape, pos) when elem(tape, pos) == 99 do
		tape
	end

	def step(_tape, _pos) do
		raise "Invalid opcode!"
	end
end

result = tape |> put_elem(1, 12) |> put_elem(2, 2)
|> AOC.step(0)
|> elem(0)

IO.puts result
