#!/usr/bin/env bash

#ruby ./22_check_static_library_symbols.rb /Users/wesley_chen/8/DingGov-iOS/Pods -c -w FLEX,MtopSDK,DGFaceLivenessModule,VerifyFaceSDK --no-color > ~/Downloads/symbol_conflict2.txt

#ruby ./22_check_static_library_symbols.rb /Users/wesley_chen/8/DingGov-iOS/Pods -c -w FLEX,MtopSDK,DGFaceLivenessModule,VerifyFaceSDK -b /Users/wesley_chen/Downloads/analysis/ld_dingding_static_library_list.txt --no-color > ~/Downloads/symbol_conflict_dingding.txt

ruby ./22_check_static_library_symbols.rb /Users/wesley_chen/8/DingGov-iOS/Pods -D -b /Users/wesley_chen/Downloads/analysis/ld_dingding_static_library_list.txt --no-color > ~/Downloads/symbol_dependency.html

#ruby ./22_check_static_library_symbols.rb /Users/wesley_chen/8/DingGov-iOS/Pods -D -b /Users/wesley_chen/Downloads/analysis/ld_dingding_static_library_list.txt --no-color --no-html > ~/Downloads/symbol_dependency.txt
