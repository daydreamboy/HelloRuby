#encoding: utf-8

require_relative '../ruby_tools'

Log.i('This is an Info')
Log.d('This is a Debug')
Log.d('This is a Debug, but never print', true, false)
Log.d('This is a Debug without dump mode', false)
Log.e('This is an Error')
Log.w('This is a Warning')
