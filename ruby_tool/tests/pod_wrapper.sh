#!/usr/bin/env bash

pod update --fast-mode
ruby pod_post_install_tool.rb addSourceFile --target=DummyAddSourceFileToTarget --path=123 --group

