require "json"
require "pry-byebug"

class ScrabbleOptimizer

	def initialize(path)
		file = File.read(path)
		file_hash = JSON.parse(file)
		read_tiles(file_hash)
		filter_words(file_hash)
		read_board(file_hash)
	end

	def read_tiles(file_hash)
		tiles = file_hash["tiles"]
		@points = {}
		@quants = Hash.new(0)

		tiles.each do |tile|
			@points[tile[0]] = tile[1..-1].to_i
			@quants[tile[0]] += 1
		end
	end

	def filter_words(file_hash)
		@words = []
		words = file_hash["dictionary"]
		words.each { |word| @words << word if filter_word word }
	end

	def filter_word(word)
		quants = @quants.dup
		word.chars.each do |char|
			if quants[char] > 0
				quants[char] -= 1
			else
				return false
			end
		end
		return true
	end

	def read_board(file_hash)
		@board = file_hash["board"]
		@board.map! do |row|
			row.split(" ").map!(&:to_i)
		end
	end

	def find_optimal_in_board
		max_word = ""
		max_sum = 0
		max_i = 0
		max_j = 0
		horizontal = true
		@words.each do |word_letters|
			word_points = convert_word_to_points(word_letters)
			max_sum_h, max_i_h, max_j_h = find_optimal_in_arrays(word_points, @board)
			max_sum_v, max_j_v, max_i_v = find_optimal_in_arrays(word_points, @board.transpose.inspect)
			if max_sum_h > max_sum || max_sum_v > max_sum
				if max_sum_h > max_sum_v
					max_sum = max_sum_h
					max_i = max_i_h
					max_j = max_j_h
					max_word = word_letters
					horizontal = true
				else
					max_sum = max_sum_v
					max_i = max_i_v
					max_j = max_j_v
					max_word = word_letters
					horizontal = false
				end
			end
		end
		return max_word, max_sum, max_i, max_j, horizontal
	end

	def convert_word_to_points(word_letters)
		word_points = []
		word_letters.chars.each do |char|
			word_points << @points[char]
		end
		return word_points
	end

	def find_optimal_in_arrays(word, arrays)
		max_sum = 0
		max_i = 0
		max_j = 0
		(0...arrays.length).each do |j|
			sum, i = find_optimal_in_array(word, arrays[j])
			if sum > max_sum
				max_sum = sum
				max_i = i
				max_j = j
			end
		end
		return max_sum, max_i, max_j
	end

	def find_optimal_in_array(word, array)
		max_sum = 0
		max_i = 0
		(0..array.length - word.length).each do |i|
			array_segment = array[0 + i...word.length + i]
			sum = (0...word.count).inject(0) {|r, j| r + word[j]*array_segment[j]}
			if sum > max_sum
				max_sum = sum
				max_i = i
			end
		end
		return max_sum, max_i
	end

end
