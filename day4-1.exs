{:ok, input} = File.read("inputs/day4.txt")

defmodule AOC do
	def verify_increasing([digit | tail], biggest) do
		if digit >= biggest do
			verify_increasing(tail, digit)
		else
			false
		end
	end

	def verify_increasing([], _biggest) do
		true
	end

	def verify_double([digit | tail], last) do
		if digit == last do
			true
		else
			verify_double(tail, digit)
		end
	end

	def verify_double([], _last) do
		false
	end

	def apply_to(num) do
		digits = num |> Integer.digits

		verify_double(digits, 0) and verify_increasing(digits, 0)
	end

	def run([start, finish]) do
		range = Range.new(start, finish)

		range |> Enum.count(&AOC.apply_to/1)
	end
end

input |> String.trim |> String.split("-")
|> Enum.map(&String.to_integer/1)
|> AOC.run
|> IO.puts
