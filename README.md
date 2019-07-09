# Ruby Notes

[TOC]

## 1、Ruby语法



### （1）dangerous方法

```ruby
class String
  def dangerous_method!
    self.upcase!; # Note: change self itself
  end
end

def test_dangerous_method
  foo = 'this is a string'
  foo.dangerous_method! # Note: change foo itself
  puts foo
end
```

​      Ruby约定，方法名以`!`结尾，表示这个方法会修改对象本身或者对象内部状态，称为dangerous方法。例如String的`upcase!`方法。





## 2、常用Ruby函数



### （1）shell command调用

#### system

格式：**system([env,] command... [,options]) → true, false or nil**

作用：产生一个子shell，执行command

说明：

返回nil，表示命令执行出错

> system returns `true` if the command gives zero exit status, `false` for non zero exit status. Returns `nil` if command execution fails. An error status is available in `$?`.



### （2）JSON解析

#### json库

Ruby内置提供json库，`require 'json'`。

* JSON String转Object，`JSON.parse`

* Object转JSON String，`JSON.dump`或者`JSON.pretty_generate`。如果需要自定义格式输出JSON字符串，使用`JSON.pretty_generate`

示例代码见json_serialization.rb





## 3、RDoc语法

[RDoc](https://ruby.github.io/rdoc/)是Ruby代码的注释生成文档的工具，包括rdoc和ri两个工具。这个[Cheatsheet](https://devhints.io/rdoc)提供RDoc支持注释形式。

除了RDoc，[YARD](https://www.rubydoc.info/gems/yard/file/docs/GettingStarted.md)也是Ruby的注释工具。



YARD支持的注释示例，如下

```ruby
# Converts the object into textual markup given a specific format.
#
# @param format [Symbol] the format type, `:text` or `:html`
# @return [String] the object converted into the expected format.
def to_format(format = :html)
  # format the object
end
```

YARD支持的[tag列表](https://www.rubydoc.info/gems/yard/file/docs/Tags.md#Tag_List)，如下

- [@abstract](https://www.rubydoc.info/gems/yard/file/docs/Tags.md#abstract)
- [@api](https://www.rubydoc.info/gems/yard/file/docs/Tags.md#api)
- [@attr](https://www.rubydoc.info/gems/yard/file/docs/Tags.md#attr)
- [@attr_reader](https://www.rubydoc.info/gems/yard/file/docs/Tags.md#attr_reader)
- [@attr_writer](https://www.rubydoc.info/gems/yard/file/docs/Tags.md#attr_writer)
- [@author](https://www.rubydoc.info/gems/yard/file/docs/Tags.md#author)
- [@deprecated](https://www.rubydoc.info/gems/yard/file/docs/Tags.md#deprecated)
- [@example](https://www.rubydoc.info/gems/yard/file/docs/Tags.md#example)
- [@note](https://www.rubydoc.info/gems/yard/file/docs/Tags.md#note)
- [@option](https://www.rubydoc.info/gems/yard/file/docs/Tags.md#option)
- [@overload](https://www.rubydoc.info/gems/yard/file/docs/Tags.md#overload)
- [@param](https://www.rubydoc.info/gems/yard/file/docs/Tags.md#param)
- [@private](https://www.rubydoc.info/gems/yard/file/docs/Tags.md#private)
- [@raise](https://www.rubydoc.info/gems/yard/file/docs/Tags.md#raise)
- [@return](https://www.rubydoc.info/gems/yard/file/docs/Tags.md#return)
- [@see](https://www.rubydoc.info/gems/yard/file/docs/Tags.md#see)
- [@since](https://www.rubydoc.info/gems/yard/file/docs/Tags.md#since)
- [@todo](https://www.rubydoc.info/gems/yard/file/docs/Tags.md#todo)
- [@version](https://www.rubydoc.info/gems/yard/file/docs/Tags.md#version)
- [@yield](https://www.rubydoc.info/gems/yard/file/docs/Tags.md#yield)
- [@yieldparam](https://www.rubydoc.info/gems/yard/file/docs/Tags.md#yieldparam)
- [@yieldreturn](https://www.rubydoc.info/gems/yard/file/docs/Tags.md#yieldreturn)





## 4、gem命令使用



### （1）常用命令

| 命令                            | 作用                   |
| ------------------------------- | ---------------------- |
| gem help commands               | 打印所有命令的帮助信息 |
| gem help COMMAND                | 查看特定命令的帮助信息 |
| gem sources --list              | 查看gem源列表          |
| gem sources --add SOURCE_URI    | 添加特定的源           |
| gem sources --remove SOURCE_URI | 删除特定的源           |
|                                 |                        |



### （2）gem源列表

https://gems.ruby-china.com/



### （3）常用Gem



| gem名称              | 作用                          |
| -------------------- | ----------------------------- |
| update_xcode_plugins | 安装Xcode Plugin后重签名Xcode |





## 5、rvm命令使用





## References


