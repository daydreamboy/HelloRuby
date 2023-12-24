#!/usr/bin/env bash

ruby ../xcscheme_tool.rb --xcodeproj=./DummyModifyXcscheme/DummyModifyXcscheme.xcodeproj --scheme=DummyModifyXcscheme --envVars DYLD_INSERT_LIBRARIES=path/to/xxx,DYLD_INSERT_LIBRARIES2=path/to/xxx2 --debug
