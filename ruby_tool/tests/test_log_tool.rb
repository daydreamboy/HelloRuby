#encoding: utf-8

require_relative '../ruby_tools'

flag = true

Log.i('This is an Info')
Log.d('This is a Debug')
Log.d('This is a Debug2', flag)
Log.e('This is an Error')
Log.w('This is a Warning')
