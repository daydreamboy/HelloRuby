# Ruby Notes

[TOC]

## 1、Ruby语法

### （1）数据类型

Ruby中所有数据都是基于类的，即基本类型（整型、浮点数）也是对象。数据类型，有如下几种[^2]

- Booleans and nil（TrueClass/FalseClass、NilClass）
- Numbers（Integer、Float、Fixnum）
- Strings（String）
- Symbols（Symbol）
- Arrays（Array）
- Hashes（Hash）
- Ranges（Range）
- Regular Expressions（Regexp）
- Procs（Proc）



irb中输出，如下

```ruby
2.4.0 :001 > true.class
 => TrueClass 
2.4.0 :002 > false.class
 => FalseClass 
2.4.0 :003 > nil.class
 => NilClass 
2.4.0 :004 > "Ruby".class
 => String 
2.4.0 :005 > 1.class
 => Integer 
2.4.0 :006 > 4.5.class
 => Float 
2.4.0 :007 > 3_463_456_457.class
 => Integer 
2.4.0 :008 > :age.class
 => Symbol 
2.4.0 :009 > [1, 2, 3].class
 => Array 
2.4.0 :010 > h = {:name => "Jane", :age => 17}
 => {:name=>"Jane", :age=>17} 
2.4.0 :011 > h.class
 => Hash 
2.4.0 :012 > (1..2).class
 => Range 
2.4.0 :013 > /.*/.class
 => Regexp 
2.4.0 :014 > -> { 1 + 1 }.class
 => Proc 
```



示例代码见data_type.rb



### （2）Ruby方法

#### a. dangerous方法

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



#### b. 返回值类型为bool的方法

​       Ruby约定，方法名以`?`结尾，表示这个方法的返回值类型是bool，例如Object提供的`is_a?`函数和`kind_of?`函数。





### （3）Ruby方法传参方式[^3]

Ruby方法传参方式，归纳有下面几种

- 正常传参方式，参数有序性
- 可选参数，参数有序性
- keyword参数，参数无序性
- 可变参数列表

> 示例代码，见
>
> method_argument_1_normal.rb
>
> method_argument_2_optional.rb
>
> method_argument_3_keyword.rb
>
> method_argument_4_variable_list_as_array.rb
>
> method_argument_5_variable_list_as_hash.rb



#### a. 正常传参方式

正常传参方式：实参和形参是一一对应的，而且实参要保证顺序。



举个例子，如下

```ruby
def write(file, data, mode)
  ...
end
```

write方法有三个参数，必须按照顺序传入3个实参。



#### b. 可选参数

可选参数：参数有默认值，该形参对应的实参可以不传，使用默认值。



注意：

> 1. 两个及以上可选参数总是位于正常参数之后，而且可选参数可以有多个。否则，脚本执行报错。
>
> 举个错误的例子，如下
>
> ```ruby
> def write3(file, data, mode = "w", size, name = "default")
> end
> 
> $ syntax error, unexpected '=', expecting ')'
> data, mode = "w", size, name = "default")
>                            ^
> $ syntax error, unexpected ')', expecting end-of-input
> = "w", size, name = "default")
>                            ^
> ```
>
> 正确形式是
>
> ```ruby
> def write3_fixed(file, data, size, mode = "w", name = "default")
> end
> ```
>
> 2. 一个可选参数，允许在正常参数之前。举个例子，如下
>
> ```ruby
> def write2(file = 'default', data, mode, size)
>   ...
> end
> 
> ```
>
> 调用根据参数个数，自动匹配对应参数，如下
>
> write2(`data` "cats are cool!", `mode` "w", `size` 10)
> write2(`file` "cats.txt", `data` "cats are cool!", `mode` "r", `size` 10)





#### c. keyword参数

keyword参数，指形参后面跟一个冒号，表示实参必须以键值对的形式传入。

keyword参数的好处是实参可以不用保序，而且调用有key做描述，不用转到方法签名处，更加清楚。



举个例子

```ruby
# Note: the last is optional keyword argument
def write(file:, data:, mode: "rw")
  ...
end

# Note: keyword argument mixed with normal argument
def write2(file, data:, mode: "rw")
  ...
end

write(data: 123, file: "test.txt")
write2("test.txt", data: 123, mode: 'r')
```

注意：

> keyword参数，要求实参必须以键值对的形式传入，否则脚本执行出错



#### d. 可变参数列表

可变参数列表分为两种：传入多个正常参数，和传入多个keyword参数



##### 1. 传入多个正常参数，可用splat operator(`*`)来接收

举个例子

```ruby
def print_all(*args)
  # Note: args is an array, but *args is a placeholder which expanded as literal elements
  dump_object(args)

  # Note: expand *args as 1, 2, 3, 4, 5
  method_with_5_args(*args)
end

print_all(1, 2, 3, 4, 5)
```

在print_all函数中args变成一个数组对象，如果再对它使用splat operator(`*`)，则展开为字面数组。例如`method_with_5_args(*args)`，*arg展开为5个参数传给method_with_5_args函数



##### 2. 传入多个keyword参数，可用double splat operator(`**`)来接收

举个例子

```ruby
def print_all(**args)
  # Note: args is a hash
  dump_object(args)

  # Note: expand *args as [:x, 1], [:y, 2]
  method_with_2_arguments *args

  # Note: **args also a hash
  dump_object(**args)
end

print_all(x: 1, y: 2)
```

在print_all函数中args变成一个Hash对象，而*args将Hash对象转成数组，**args还是本身的Hash对象



#### e. 混合多种传参方式

根据上面几种传参方式，可以混合使用，因此存在优先级：required -> optional -> variable -> keyword

```ruby
# Note: required -> optional -> variable -> keyword
def testing(a, b = 1, *c, d: 1, **x)
  # p a,b,c,d,x
  dump_object(a)
  dump_object(b)
  dump_object(c)
  dump_object(d)
  dump_object(x)
end

testing('a', 'b', 'c', 'd', 'e', d: 2, x: 1)
```

`**x`和d: 1都属于keyword参数，`*c`属于variable参数

> 示例代码，见method_argument_6_mixed.rb



#### d. 接收所有参数

Ruby方法传参可以使用通配符`*`，接收所有参数。此方式不常见，但配合super方法可以将参数透传给父类方法。

举个例子，如下

```ruby
class Food
  def nutrition(vitamins, minerals)
    puts vitamins
    puts minerals
  end
end

class Bacon < Food
  def nutrition(*)
    super
  end
end

bacon = Bacon.new
bacon.nutrition("B6", "Iron")
```

Food的nutrition方法的参数个数修改了，不影响子类Bacon的nutrition方法。



### （4）Ruby注释方式[^4]

Ruby的单行注释使用`#`，而多行注释则有下面几种方式

```ruby
# 1. =begin...=end

=begin
Every body mentioned this way
to have multiline comments.

The =begin and =end must be at the beginning of the line or
it will be a syntax error.
=end

# 2. Here doc style

<<-DOC
Also, you could create a docstring.
which...
DOC

# 3. literal string

"..is kinda ugly and creates
a String instance, but I know one guy
with a Smalltalk background, who
does this."

# 4. sharp sign

##
# most
# people
# do
# this

# 5. __END__ sign

__END__

But all forgot there is another option.
Only at the end of a file, of course.
```

> 示例代码，见block_comment.rb





## 2、常用Ruby函数



### （1）shell command调用

#### system

格式：**system([env,] command... [,options]) → true, false or nil**

作用：产生一个子shell，执行command

说明：

返回nil，表示命令执行出错。

返回true，表示命令执行返回状态为0。

返回false，表示命令执行返回状态为非0。

官方描述，如下

> system returns `true` if the command gives zero exit status, `false` for non zero exit status. Returns `nil` if command execution fails. An error status is available in `$?`.





### （2）JSON解析

#### json库

Ruby内置提供json库，`require 'json'`。

* JSON String转Object，`JSON.parse`

* Object转JSON String，`JSON.dump`或者`JSON.pretty_generate`。如果需要自定义格式输出JSON字符串，使用`JSON.pretty_generate`

示例代码见json_serialization.rb



## 4、常用Ruby Tips

### （1）Shell和Ruby脚本通信

ruby脚本通过shell执行，shell和ruby脚本可以进行交互。



#### a. shell将数据传给ruby

shell将数据传给ruby，有两种方式：命令行参数、shell环境变量

* 命令行参数。执行ruby脚本时，将数据作为参数传给ruby脚本。

  ```shell
  $ ruby 03_pass_shell_command_to_script.rb ruby 03_callee.rb
  或者
  $ ./03_pass_shell_command_to_script.rb ruby 03_callee.rb
  ```

  这里`ruby 03_callee.rb`是ruby脚本接收的参数，可以通过`ARGV`预定义变量[^1]拿到。示例代码，见03_pass_shell_command_to_script.rb

* shell环境变量。执行ruby脚本前，用export命令将数据导入到当前shell的环境变量中。ruby脚本通过`ENV`来访问。示例代码，见04_pass_shell_env_var_to_script.rb



#### b. ruby将数据传给shell

​       ruby将数据传给shell的方式：可以利用ruby执行export命令将数据导出到当前shell环境变量中。

注意：

> 这种方式需要shell按照特殊实行执行ruby代码或者ruby脚本。



​        如果直接在shell中，执行`ruby xxx.rb`，xxx.rb使用system函数导出环境变量，在当前shell中，获取不到这个环境变量。举个例子

```shell
$ ruby -e "system('export foo=bar')"; echo $foo
$ (empty here)
```

借助shell的`eva`l函数和<code>\`command`</code>函数，如下

```shell
$ eval `ruby -e "puts 'export foo=bar'"`; echo $foo
$ bar
```

上面的eval函数执行的内容，实际是<code>\`command`</code>函数执行后输出的结果，因此是ruby的puts函数的输出内容。



换成执行ruby脚本方式，如下

```shell
eval `ruby './05_export_env_var_from_script_to_shell.rb'`

echo "ruby_secret1 = $ruby_secret1"
echo "ruby_secret2 = $ruby_secret2"
echo "ruby_secret3 = $ruby_secret3"
```

示例代码，见05_export_env_var_from_script_to_shell.rb/sh





## 5、RDoc语法

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





## 6、gem命令使用



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





## 7、rvm命令使用



## 附录



### （1）Ruby预定义变量[^1]



| 变量名 | 值类型 | 作用                                                    |
| ------ | ------ | ------------------------------------------------------- |
| ARGV   | Array  | 命令行参数（除ruby脚本文件名之外的参数），是`$*.`的别名 |
| ENV    | Hash   | 当前shell的环境变量                                     |







## References

[^1]:http://ruby-doc.org/core-2.6.3/doc/globals_rdoc.html#label-Pre-defined+variables Ruby预定义变量

[^2]:https://docs.ruby-lang.org/en/2.0.0/syntax/literals_rdoc.html Ruby数据类型

[^3]: https://www.rubyguides.com/2018/06/rubys-method-arguments/

[^4]:https://stackoverflow.com/a/2991254



