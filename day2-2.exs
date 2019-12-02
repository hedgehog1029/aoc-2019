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

	def try_input(tape, noun, verb) do
		tape |> put_elem(1, noun) |> put_elem(2, verb) |> AOC.step(0) |> elem(0)
	end

	def iterate_nv(tape, test, [{noun, verb} | tail]) do
		if tape |> try_input(noun, verb) == test do
			{:done, noun, verb}
		else
			iterate_nv(tape, test, tail)
		end
	end

	def iterate_nv(_tape, _test, []) do
		{:fail}
	end

	def iterate_nv(tape, test) do
		poss = for noun <- 1..99, verb <- 1..99, do: {noun, verb}

		iterate_nv(tape, test, poss)
	end
end

{:done, noun, verb} = tape |> AOC.iterate_nv(19690720)
IO.puts (100 * noun + verb)
