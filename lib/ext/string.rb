class String
	def upcase_first_word
		split(' ').map{|x| x.upcase_first }.join(' ')
	end
end