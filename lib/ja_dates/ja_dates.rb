# coding: utf-8
# JaDates
# by Scott Murphy (http://www.scott-murphy.net)
 
module Ja_Dates
	def calc_ja(option)
	  	year = option.strftime('%Y').to_i
		case year 
		when 0..1925
			 return "#{year}年"
		when 1926..1988 
			 return '昭和' + "#{year - 25 - 1900}年"
		when 1989
			 return '平成元年'
	    else 
		    return '平成' + "#{year + 12 - 2000}年"
		end
	end

	def ja_md(option)
		option.strftime('%m' + '月' + '%d' + '日') 
	end
	
	def ja_mdy(option)
		option.strftime('%m' + '月' + '%d' + '日' + '%Y' + '年' )
	end
	
	def ja_wmd(option)
		 calc_ja(option) + option.strftime('%m' + '月' + '%d' + '日' )  
	end

	def ja_wm(option)
		 calc_ja(option) + option.strftime('%m' + '月')  
	end
end
