# HelloRubyGems
--
TOC

* hello\_command\_line，介绍如何写一个带有命令行工具的ruby gem[^1]


关于工程名的说明
>
由于ruby gem的名称一般都是小写，所以这里的ruby gems都是小写命名。

## hello\_command\_line

1\. 使用bundler创建gem模板

```
bundle gem hello_command_line
```

如果没有安装bundler，则gem install bunlder。bundle命令创建模板的同时，也创建了一个git仓库，模板结构如下

```
$ tree 
.
├── Gemfile
├── LICENSE.txt
├── README.md
├── Rakefile
├── bin
│   ├── console
│   └── setup
├── hello_command_line.gemspec
└── lib
    ├── hello_command_line
    │   └── version.rb
    └── hello_command_line.rb

3 directories, 9 files
```

基本原理是，在bin文件夹下创建一个<b>可执行的不带后缀名</b>的ruby脚本（后简称<b>launcher脚本</b>），它是命令行工具，同时它引入lib/hello\_command\_line.rb做真正的执行过程。

>
可选的步骤：如果还需要依赖其他的gem，但是不希望安装到默认的ruby gem环境中，则使用`rvm gemset create <new gemset>`，创建一个干净的ruby gem环境。

2\. 编辑hello\_command\_line.rb

```
require "hello_command_line/version"

module HelloCommandLine
  class Chatter
    def say_hello
      puts 'This is a command tool written by ruby.'
    end
  end
end
```

3\. bin下创建launcher脚本

```
#!/usr/bin/env ruby

require 'hello_command_line'

chatter = HelloCommandLine::Chatter.new
chatter.say_hello
```

顶部添加shebang，指定使用ruby解释器。下面引入lib/hello\_command\_line.rb，使用该文件类的实例方法。

>
注意：去掉后缀名，同时chmod +x

4\. 修改.gemspec文件

.gemspec文件描述如何打包gem，修改后的内容如下

```
# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hello_command_line/version"

Gem::Specification.new do |spec|
  spec.name          = "hello_command_line"
  spec.version       = HelloCommandLine::VERSION
  spec.authors       = ["daydreamboy"]
  spec.email         = ["wesley4chen@gmail.com"]

  spec.summary       = %q{An example for how to create a command line tool using ruby gem.}
  spec.description   = %q{This is a demo.}
  spec.homepage      = 'https://github.com/daydreamboy/HelloRubyGems'
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  # spec.bindir        = "exe"
  spec.executables   = ['hello_command_line'] #spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
end
```

.gemspec文件由模板生成，需要修复几个TODO，不然rake install会报错。这里最主要的是，用`spec.executables`指定launcher脚本，同时注释掉`spec.bindir`，因为launcher脚本不在exe目录下面。

5\. 使用rake命令打包和安装gem

在gem工程根目录下，执行rake install，即完成打包和安装的过程。

```
$ rake install
hello_command_line 0.1.0 built to pkg/hello_command_line-0.1.0.gem.
hello_command_line (0.1.0) installed.
```
>
rake install --trace，显示执行步骤

gem会被安装到当前gemset中，所以执行rake命令前，可以先确认一下。
最后测试一下，hello\_command\_line命令是否可以用。

```
$ hello_command_line
This is a command tool written by ruby.
```

>
也可以不使用rake命令，在gem工程根目录下，执行`gem build hello_command_line`，然后执行`gem install ./hello_command_line-0.1.0.gem`


References
--
[^1]: http://robdodson.me/how-to-write-a-command-line-ruby-gem/
