defmodule Intcode do
	def opcode(n) do
		if n > 99 do
			n |> Integer.digits |> Enum.slice(-2, 2) |> Integer.undigits
		else
			n
		end
	end

	def at(tape, pos) do
		elem(tape, pos)
	end

	def opcode_at(tape, pos) do
		at(tape, pos) |> opcode
	end

	def param_expander(initial, remaining) when remaining > 0 do
		[0 | initial] |> param_expander(remaining - 1)
	end

	def param_expander(result, _) do
		result
	end

	def parse_param_mode(pm) do
		case pm do
			0 -> :pointer
			1 -> :immediate
			_ -> raise "Invalid parameter mode!"
		end
	end

	def param_modes(n) do
		parts = n |> Integer.digits
		remaining = 5 - (parts |> Enum.count)
		
		[third, second, first] = parts |> param_expander(remaining) |> Enum.slice(0..-3)
			|> Enum.map(&Intcode.parse_param_mode/1)

		[first, second, third]
	end

	def param_modes_at(tape, pos) do
		at(tape, pos) |> param_modes
	end

	def action_reducer(tape, pos, mode, offset) do
		case mode do
			:pointer -> elem(tape, pos + offset)
			:immediate -> pos + offset
		end
	end

	def input_helper() do
		line = case IO.gets("Input>> ") do
			:eof -> raise "stdin eof"
			{:error, reason} -> raise "stdin #{reason}"
			data -> data
		end

		case Integer.parse(line) do
			:error ->
				IO.puts "Invalid integer."
				input_helper()
			{n, _} -> n
		end
	end

	def bool_to_intcode(bool) do
		if bool do
			1
		else
			0
		end
	end

	# add
	def step(tape, pos, 1, [am, bm, rm]) do
		a = elem(tape, am.(1))
		b = elem(tape, bm.(2))

		tape = put_elem(tape, rm.(3), a + b)
		{tape, pos + 4}
	end

	# multiply
	def step(tape, pos, 2, [am, bm, rm]) do
		a = elem(tape, am.(1))
		b = elem(tape, bm.(2))

		tape = put_elem(tape, rm.(3), a * b)
		{tape, pos + 4}
	end

	# read_in
	def step(tape, pos, 3, [rm | _]) do
		tape = put_elem(tape, rm.(1), input_helper())
		
		{tape, pos + 2}
	end

	# print_out
	def step(tape, pos, 4, [am | _]) do
		elem(tape, am.(1)) |> IO.puts

		{tape, pos + 2}
	end

	# jump-if-true
	def step(tape, pos, 5, [am, bm, _]) do
		if elem(tape, am.(1)) != 0 do
			{tape, elem(tape, bm.(2))}
		else
			{tape, pos + 3}
		end
	end

	# jump-if-false
	def step(tape, pos, 6, [am, bm, _]) do
		if elem(tape, am.(1)) == 0 do
			{tape, elem(tape, bm.(2))}
		else
			{tape, pos + 3}
		end
	end

	# less than
	def step(tape, pos, 7, [am, bm, rm]) do
		val = elem(tape, am.(1)) < elem(tape, bm.(2))
		tape = put_elem(tape, rm.(3), val |> bool_to_intcode)

		{tape, pos + 4}
	end

	# equals
	def step(tape, pos, 8, [am, bm, rm]) do
		val = elem(tape, am.(1)) == elem(tape, bm.(2))
		tape = put_elem(tape, rm.(3), val |> bool_to_intcode)

		{tape, pos + 4}
	end

	# halt
	def step(tape, _pos, 99, _) do
		{tape, -1}
	end

	# Invalid opcode fallthrough
	def step(tape, pos, _, _) do
		raise "Invalid opcode #{opcode_at(tape, pos)}!"
	end

	def execute({tape, pos}) when pos >= 0 do
		opcode = tape |> opcode_at(pos)
		modes = param_modes_at(tape, pos)
			|> Enum.map(fn mode -> &action_reducer(tape, pos, mode, &1) end)

		tape |> step(pos, opcode, modes) |> execute
	end

	def execute({tape, _pos}) do
		tape
	end

	def execute(tape, pos) do
		execute({tape, pos})
	end
end
