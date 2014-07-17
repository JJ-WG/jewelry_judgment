require ::File.expand_path('../../../lib/ja_dates/ja_dates',  __FILE__)
#require File.dirname(__FILE__) + '../..//lib/ja_dates'
ActionView::Base.send :include, Ja_Dates
