#!/usr/bin/env bash

pod install --no-repo-update
ruby ../../pod_post_install_tool.rb addSourceFile --target=DummyAddSourceFileToTarget --path=./Podfile --group=../AwesomeDebugger
