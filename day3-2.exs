{:ok, input} = File.read("inputs/day3.txt")

defmodule AOC do
	def handle_intersect({old, oldstep}, {new, step}) do
		case {old, new} do
			{:first, :second} -> {:intersect, oldstep + step}
			{:second, :first} -> raise "Invalid map crossing?"
			_ -> {old, oldstep}
		end
	end

	def draw_line(grid, step, {x, y}, {:up, i, distance}, ident) do
		if distance == i do
			{grid, step}
		else
			grid |> Map.update({x, y + i}, {ident, step}, &handle_intersect(&1, {ident, step}))
			|> draw_line(step + 1, {x, y}, {:up, i + 1, distance}, ident)
		end
	end

	def draw_line(grid, step, {x, y}, {:down, i, distance}, ident) do
		if distance == i do
			{grid, step}
		else
			grid |> Map.update({x, y - i}, {ident, step}, &handle_intersect(&1, {ident, step}))
			|> draw_line(step + 1, {x, y}, {:down, i + 1, distance}, ident)
		end
	end

	def draw_line(grid, step, {x, y}, {:right, i, distance}, ident) do
		if distance == i do
			{grid, step}
		else
			grid |> Map.update({x + i, y}, {ident, step}, &handle_intersect(&1, {ident, step}))
			|> draw_line(step + 1, {x, y}, {:right, i + 1, distance}, ident)
		end
	end
	
	def draw_line(grid, step, {x, y}, {:left, i, distance}, ident) do
		if distance == i do
			{grid, step}
		else
			grid |> Map.update({x - i, y}, {ident, step}, &handle_intersect(&1, {ident, step}))
			|> draw_line(step + 1, {x, y}, {:left, i + 1, distance}, ident)
		end
	end

	def follow({grid, step}, {x, y}, [{:up, distance} | tail], ident) do
		grid |> draw_line(step, {x, y}, {:up, 0, distance}, ident)
		|> follow({x, y + distance}, tail, ident)
	end

	def follow({grid, step}, {x, y}, [{:down, distance} | tail], ident) do
		grid |> draw_line(step, {x, y}, {:down, 0, distance}, ident)
		|> follow({x, y - distance}, tail, ident)
	end

	def follow({grid, step}, {x, y}, [{:right, distance} | tail], ident) do
		grid |> draw_line(step, {x, y}, {:right, 0, distance}, ident)
		|> follow({x + distance, y}, tail, ident)
	end

	def follow({grid, step}, {x, y}, [{:left, distance} | tail], ident) do
		grid |> draw_line(step, {x, y}, {:left, 0, distance}, ident)
		|> follow({x - distance, y}, tail, ident)
	end

	def follow(result, _, [], _) do
		result
	end

	def closest_steps(grid) do
		grid |> Enum.filter(fn {_, {n, _}} -> n == :intersect end)
		|> Enum.map(fn {_, {_, steps}} -> steps end)
		|> Enum.min
	end

	def parse(command) do
		{direction, distance} = command |> String.split_at(1)
		distance = distance |> String.to_integer

		case direction do
			"U" -> {:up, distance}
			"R" -> {:right, distance}
			"L" -> {:left, distance}
			"D" -> {:down, distance}
			_ -> raise "Invalid direction!"
		end
	end

	def parse_input(input) do
		input |> String.split(",") |> Enum.map(&parse/1)
	end

	def run(input) do
		[first, second] = input |> String.trim |> String.split |> Enum.map(&parse_input/1)

		grid = %{}
		{grid, _} = follow({grid, 0}, {0, 0}, first, :first)
		{grid, _} = follow({grid, 0}, {0, 0}, second, :second)

		%{grid | {0, 0} => {:center, 0}} |> closest_steps
	end
end

IO.puts(input |> AOC.run)
