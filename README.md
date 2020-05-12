# Ruby Notes

[TOC]

## 1、Ruby语法

### （1）基本数据类型

#### a. class & module

| 特性         | class                               | module                                |
| ------------ | ----------------------------------- | ------------------------------------- |
| 容器功能     | 可以包含实例方法、类方法等          | 仅包含方法和常量                      |
| 是否能实例化 | 是                                  | 否                                    |
| 继承性       | 可以继承其他class，但不能继承module | 不能继承                              |
| mix-ins功能  | class不能被mix in到任意             | 有。可以mix in到其他module或者class中 |



以上摘自官方文档[^11]，如下

> ### What is the difference between a class and a module?
>
> Modules are collections of methods and constants. They cannot generate instances. Classes may generate instances (objects), and have per-instance state (instance variables).
>
> Modules may be mixed in to classes and other modules. The mixed in module’s constants and methods blend into that class’s own, augmenting the class’s functionality. Classes, however, cannot be mixed in to anything.
>
> A class may inherit from another class, but not from a module.
>
> A module may not inherit from anything.



#### b. class variable & class instance variable



#### c. Object

​       Object是用户定义class的基类，即使不显示使用继承，默认基类也是Object。可以通过ancestors方法，查看继承顺序，如下

```ruby
class Klass
end

puts Klass.ancestors.inspect # [Klass, Object, Kernel, BasicObject]
```



##### send方法

send方法，是一个运行时方法，可以在运行时调用接受者的方法。接受者可以是对象或者类。

签名如下

```ruby
send(symbol [, args...]) → obj
send(string [, args...]) → obj
```



举个例子，如下

```ruby
class Klass
  def hello(*args)
    puts "Hello " + args.join(' ')
  end

  def self.Hello(*args)
    puts "Hello2 " + args.join(' ')
  end
end

k = Klass.new
k.send :hello, "gentle", "readers"   #=> "Hello gentle readers"
# use send method by runtime, is same as the following line
k.hello "gentle", "readers"
Klass.send :Hello, 'gentle2', 'readers2'
```

> 示例代码，见Object_method_send.rb





### （2）literals数据类型

Ruby中所有数据都是基于类的，即基本类型（整型、浮点数）也是对象。literals数据类型，有如下几种[^2]

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

> 示例代码见data_type.rb



#### String



##### sub方法和gsub方法

String提供sub实例方法和gsub实例方法，用字符串替换。

* sub实例方法，只替换满足匹配的首个字符串
* gsub（global sub）实例方法，全局替换满足匹配的所有字符串

> sub和gsub方法，对应有修改入参字符串的版本：sub!和gsub!方法



以gsub方法为例，其方法签名，如下

```ruby
gsub(pattern, replacement) → new_str
gsub(pattern, hash) → new_str
gsub(pattern) {|match| block } → new_str
gsub(pattern) → enumerator
```

pattern参数，可以是字符串或者Regexp对象。

举个例子，如下

```ruby
def gsub_with_string_pattern(string)
  string.gsub('potato', 'banana')
end

def gsub_with_Regexp_pattern(string)
  string.gsub(/p[a-zA-Z]+o/, 'banana')
end

def gsub_with_Regexp_pattern_anchored(string)
  string.gsub(/^p[a-zA-Z]+o$/, 'banana')
end

dump_object(gsub_with_string_pattern("One potato, two potato, three potato, four."))
dump_object(gsub_with_Regexp_pattern("One potato, two potato, three potato, four."))
dump_object(gsub_with_Regexp_pattern_anchored("One potato, two potato, three potato, four."))
```

注意，pattern参数是字符串，即使字符串是正则表达式，不会按照正则匹配。举个例子，如下

```ruby
def gsub_with_string_pattern_literal(string)
  string.gsub('\d+', "[number]")
end

dump_object(gsub_with_string_pattern_literal("ff001.png"))
dump_object(gsub_with_string_pattern_literal('pattern is \d+')) # output: "pattern is [number]"
```



##### gsub方法的capture group

gsub方法，支持将满足正则匹配的字符串换成动态的捕获变量值。举个例子，如下

```ruby
def regexp_capture_group(string)
  string.gsub(/(\d+)/, '\1')
end

def regexp_capture_group_anchored(string)
  string.gsub(/[a-zA-Z]*(\d+)/, '\1')
end

dump_object(regexp_capture_group('aaa074')) # output: "aaa074"
dump_object(regexp_capture_group_anchored('aaa074')) # output: "074"
```

* aaa074按照`/(\d+)/`匹配，满足匹配的是074换成捕获变量值074，所以最终替换后的字符串是aaa074
* aaa074按照`/[a-zA-Z]*(\d+)/`匹配，满足匹配的是aaa074换成捕获变量值074，所以最终替换后的字符串是074



#### Regexp

Regexp类用于表示正则表达式。



##### 初始化Regexp

Regexp初始化有三种方式

* /xxx/方式
* %r{xxx}方式
* 使用new方法的方式

举个例子，如下

```ruby
def create_with_forward_slashes
  return /hay/
end

def create_with_r_percent_literal
  return %r{hay}
end

def create_with_new
  return Regexp.new('hay')
end
```

> 示例方法，见data_type_Regexp_create.rb



##### match方法

Regexp实例提供match方法，用于匹配字符串。如果存在匹配，则该方法返回MatchData实例，否则返回nil。

举个例子，如下

```ruby
def create_with_forward_slashes
  return /hay/
end

match_data = create_with_forward_slashes.match('haystack')

dump_object(match_data)
dump_object("original string: #{match_data.string}")
dump_object("matched string: #{match_data.to_s}")
```

MatchData的string方法返回原始需要匹配的字符串，而to_s方法返回满足匹配的字符串。



#### File

用于操作文件或目录



##### 重命名文件或文件夹[^10]

```ruby
File.rename './my-directory', './my-renamed-directory'
```





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

> 示例代码，见comment_block.rb



### （5）Ruby方法的block参数[^6]



#### a. Ruby方法传block参数



Ruby方法可以使用block传参，需要使用`yield`以及`block_given?`来调用和检查block。

* `yield`，在ruby方法中使用`yield`调用block，可以将block需要的参数，传给`yield`
* `block_given?`，用于检查方法的参数中是否block传入。如果不检查，传入非block参数，用`yield`调用会出现异常

举个例子，如下

```ruby
def my_method
  puts "reached the top"
  # Note: call the block parameter by using `yield`
  status = yield("John", 2) if block_given?
  puts "reached the bottom"
  puts "status code: #{status}"
end

my_method do |name, age|
  puts "Hello, #{name} in #{age} years old"
  puts "reached yield"
  1
end
```



#### b. Ruby方法同时传正常参数和block参数

Ruby方法允许同时传正常参数和block参数，但是block参数有且仅有一个[^6]，而且总是在最后一个。

举个例子，如下

```ruby
def my_map(array)
  new_array = []

  for element in array
    new_array.push yield element if block_given?
  end

  new_array
end

result = my_map([1, 2, 3]) do |number|
  number * 2
end

puts result
```

my_map方法，实际上接收两个参数，一个参数是数组，另一个参数是block

> 示例代码，见block_4_method_normal_parameter_and_block_parameter.rb





### （6）module的mix-ins功能[^12]

mix-ins功能，是指通过include或者prepend语句，将某个module的方法和常量导入到其他module或者类中。

​       相对于继承方式，mix-ins方式更加灵活，可以将多个module导入到同一个类中。而且Ruby也不支持多继承方式。为了获取父类的工具方法，采用继承方式还是比较耦合严重的。



说明

> 可以调用module的ancestors方法，来检查当前module的继承顺序



#### include语句

举个例子，如下

```ruby
require 'logger'

module Logging
  def logger
    @logger ||= Logger.new(STDOUT)
  end
end

class Person
  include Logging

  def relocate
    logger.debug "Relocating person..."
    # or
    # self.logger.debug "Relocating person..."
  end
end

p = Person.new()
p.relocate()
```

Person类导入Logging的logger实例方法，相当于自己的实例方法，因此可以使用self或者不使用self来调用实例方法。

说明

> @logger ||= Logger.new(STDOUT)写法，仅创建一次实例变量，不会创建多个



##### included方法

module的included方法，可以当module被include时，触发调用。举个例子，如下

```ruby
module A
  def A.included(mod)
    puts "module `#{self}` included in module `#{mod}`"
  end
end

module Enumerable
  include A
end
```

> 示例代码，见module_mixin_included.rb



#### prepend语句[^13]

prepend语句和include语句类似，但是它继承顺序是在当前类插入方法。

举个例子，如下

```ruby
module ServiceDebugger
  def run(args)
    puts "Service run start: #{args.inspect}"
    result = super
    puts "Service run finished: #{result}"
  end
end

class Service
  prepend ServiceDebugger

  # perform some real work
  def run(args)
    args.each do |arg|
      sleep 1
    end
    {result: "ok"}
  end
end

puts Service.ancestors.inspect()

s = Service.new()
s.run([1, 2, 3])
```

继承顺序为`[ServiceDebugger, Service, Object, Kernel, BasicObject]`，因此方法查找，也按照这个顺序，还是影响super指向哪个方法。

> 示例代码，见module_mixin_prepend.rb



#### extend语句

extend语句的作用和include类似，但是它不影响ancestor顺序，而且它导入的方法的接受者可以是类或者实例。如果接受者是类，则它导入的方法是类方法。如果接受者是实例，则它导入的方法是实例方法。



##### 向类导入类方法

举个例子，如下。因此logger方法里面也必现是类变量，而不是实例变量。

```ruby
require 'logger'

module Logging
  def logger
    @@logger ||= Logger.new(STDOUT)
  end
end

class Person
  extend Logging

  def relocate
    Person.logger.debug "Relocating1 person..."

    # could also access it with this
    self.class.logger.debug "Relocating2 person..."
  end
end

p = Person.new()
p.relocate()
```

> 示例代码，见module_mixin_extend_for_class.rb



##### 向对象导入实例方法

另外，extend语句也可以运行时针对某个对象使用。举个例子，如下

```ruby
require 'logger'

module Logging
  def logger
    @logger ||= Logger.new(STDOUT)
  end
end

class Person; end

p = Person.new
# p.logger -- this would throw a NoMethodError
p.extend Logging
p.logger.debug "just a test"
```

针对p对象，使用extend语句，添加了实例方法

> 示例代码，见module_mixin_extend_for_instance.rb



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



### （2）获取shell command输出结果[^7]



一般有下面几种方式，执行命令，但是都不能完全得到命令的正常输出以及错误输出。

```ruby
exec("echo 'hello world'") # exits from ruby, then runs the command
system('echo', 'hello world') # returns the status code
sh('echo', 'hello world') # returns the status code
`echo "hello world"` # returns stdout
%x[echo 'hello world'] # returns stdout
```



可以使用`Open3.capture3`方法，获取三个返回值。举个例子，如下

```ruby
require 'open3'
stdout, stderr, status = Open3.capture3("ls")
if status.success?
  # success
else
  # failure
end
```



> `Open3`库是Ruby内置库，可以直接使用。示例代码，见07_git-batch.rb



## 3、常用Ruby库



### （1）json库

Ruby内置提供json库

- JSON String转Object，`JSON.parse`
- Object转JSON String，`JSON.dump`或者`JSON.pretty_generate`。如果需要自定义格式输出JSON字符串，使用`JSON.pretty_generate`

> 示例代码见json_serialization.rb



### （2）optparse库

Ruby内置提供optparse库，该库中OptionParse类，用于解析CLI参数。



#### 介绍CLI参数

CLI（Command Line Interface）定义命令行工具的参数协议，对于命令行参数分为下面两种

* optional argument，可选参数（也可以配置为必选），多个可选参数和顺序无关，示例格式为`-h`或`--help`。
* positionnal argument，固定参数（可以必选或可选），多个固定参数和顺序有关

说明

> 可选参数的参数，称为parameter，示例如`--level 2`。



#### 基本用法

创建OptionParse对象时，配置on方法回调，最后调用parse方法或parse!方法，完成对CLI参数解析。

```ruby
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
end.parse!

p options
p ARGV
```

> 示例代码，见optparse_use_OptionParser.rb

​     

​       ruby脚本的接收接收CLI参数，都在ARGV变量中。在调用parse方法或parse!方法之前，ARGV中是完整CLI参数数组。parse方法和parse!方法的区别在于

* parse方法，不修改ARGV，调用后ARGV依然是完整CLI参数数组
* parse!方法，修改ARGV，调用后ARGV不是完整CLI参数数组，而过滤掉optional arguments之后的数组。

修改上面脚本的parse方法，分别执行，结果如下

```shell
# call parse
$ ruby optparse_use_OptionParser.rb hello -v
{}
["hello", "-v"]

# call parse!
ruby optparse_use_OptionParser.rb hello -v
{:verbose=>true}
["hello"]
```

​       一般需要调用parse!方法，将optional arguments和positional arguments分别存储到Hash对象（例如上面的options）和ARGV中。



如果CLI参数有OptionParser没有定义的optional arguments，则执行命令会报错，例如

```shell
ruby optparse_use_OptionParser.rb hello -v -d 12
Traceback (most recent call last):
optparse_use_OptionParser.rb:10:in `<main>': invalid option: d (OptionParser::InvalidOption)
optparse_use_OptionParser.rb:10:in `<main>': invalid option: -d (OptionParser::InvalidOption)
```



CLI参数有可以多个positional arguments，例如

```shell
$ ruby optparse_use_OptionParser.rb -v hello hello2 hello3
{:verbose=>true}
["hello", "hello2", "hello3"]
```



#### 获取所有positional arguments和optional arguments

获取所有positional arguments和optional arguments，有两种方法

* 在on方法回调中，设置到Hash对象中。

```ruby
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on('-a') do |v|
    options[:a] = v
  end

  opts.on('-b NUM') do |v|
    options[:b] = v
  end

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
end.parse!

p options
p ARGV
```

这种方式，比较细粒度控制每个optional argument的解析，可以在回调block中自定义设置的值。

执行结果，如下

```shell
$ ruby optparse_get_positional_and_optional_arguments_by_on_method.rb -a -b 3 -v hello hello2
{:a=>true, :b=>"3", :verbose=>true}
["hello", "hello2"]
```

> 示例代码，见optparse_get_positional_and_optional_arguments_by_on_method.rb



* 在parse!方法的into参数设置到Hash对象。这种方式比较简单，不用设置每个on方法的回调block

```ruby
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.on('-a')
  opts.on('-b NUM', Integer)
  opts.on('-v', '--verbose')
end.parse!(into: options)

p options
p ARGV
```

执行结果，如下

```shell
$ ruby optparse_get_positional_and_optional_arguments_by_on_method.rb -a -b 3 -v hello hello2
{:a=>true, :b=>"3", :verbose=>true}
["hello", "hello2"]
```

> 示例代码，见optparse_get_positional_and_optional_arguments_by_parse_method.rb



#### optional参数的格式

OptionParser解析optional参数，按照一定格式约定来解析。

* 按照可选参数的名字，是否简写来分类
* 按照可选参数的parameter，是否可选或者没有值来分类

如下表

|            | 必填parameter                                | 可选parameter         | 无parameter |
| ---------- | -------------------------------------------- | --------------------- | ----------- |
| 非简写参数 | "--switch=MANDATORY" or "--switch MANDATORY" | "--switch[=OPTIONAL]" | "--switch"  |
| 简写参数   | "-xMANDATORY"                                | "-x[OPTIONAL]"        | "-x"        |

说明

> 1. 简写参数，以`-`为前缀，认第一个字母为简写参数，例如-xMANDATORY，x为简写参数，而MANDATORY没有强制全部大写或者采用驼峰命名
> 2. 非简写参数，以`--`前缀，都支持非歧义下，非完整匹配。例如`--switch`等价于`--sw`、`--switc`，甚至等价于简写参数`-s`。有必填parameter或可选parameter，也是一样，`--switch=on`等价于`--sw=on`、`--switc=on`



##### 无parameter

无parameter一般用于标识flag值，存储为true和false。

```ruby
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.on('--verbose')
  opts.on('--abort')
end.parse!(into: options)

p options
p ARGV
```

执行结果，如下

```shell
# Case 1
$ ruby optparse_optional_argument_no_parameter.rb --abort --verbose
{:abort=>true, :verbose=>true}
[]
# Case 2
$ ruby optparse_optional_argument_no_parameter.rb --ab --ver     
{:abort=>true, :verbose=>true}
[]
# Case 3
$ ruby optparse_optional_argument_no_parameter.rb -a -v 
{:abort=>true, :verbose=>true}
[]
# Case 4
$ ruby optparse_optional_argument_no_parameter.rb -ab -ver  
Traceback (most recent call last):
optparse_optional_argument_no_parameter.rb:7:in `<main>': invalid option: b (OptionParser::InvalidOption)
optparse_optional_argument_no_parameter.rb:7:in `<main>': invalid option: -b (OptionParser::InvalidOption)
```

可以看出

* CLI参数的完整形式，支持非歧义下的前缀匹配（Case 1和Case 2）
* CLI参数的简写形式，只匹配首个字母（Case 3和Case 4）

> 示例代码，见optparse_optional_argument_no_parameter.rb



##### 必填parameter

```ruby
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.on('--verbose=FLAG')
  opts.on('-aflag')
end.parse!(into: options)

p options
p ARGV
```

执行结果，如下

```shell
$ ruby optparse_optional_argument_required_parameter.rb -v -a
{:verbose=>"-a"}
[]

$ ruby optparse_optional_argument_required_parameter.rb -aBBBB -ver AAA
{:a=>"BBBB", :verbose=>"er"}
["AAA"]

$ ruby optparse_optional_argument_required_parameter.rb -aBBBB --ver AAA
{:a=>"BBBB", :verbose=>"AAA"}
[]
```

> 示例代码，见optparse_optional_argument_required_parameter.rb



##### 可选parameter

```ruby
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.on('--verbose[=XXX]')
  opts.on('-a[YYY]')
end.parse!(into: options)

p options
p ARGV
```

执行结果，如下

```shell
# Case 1
$ ruby optparse_optional_argument_optional_parameter.rb --ver -a 
{:verbose=>nil, :a=>nil}
[]

# Case 2
$ ruby optparse_optional_argument_optional_parameter.rb --ver -a10 
{:verbose=>nil, :a=>"10"}
[]

# Case 3
$ ruby optparse_optional_argument_optional_parameter.rb --ver -a 10
{:verbose=>nil, :a=>nil}
["10"]
```

Ruby 2.6.3p62版本，似乎存在bug，Case 2和Case 3解析结果不一样。

> 示例代码，见optparse_optional_argument_optional_parameter.rb



#### 完整的on方法参数

on方法对于参数顺序没有要求，但是对于参数的值有一定格式规范

* 简写形式，必须以`-`为前缀，而且支持parameter的三种形式：none、required、optional
* 非简写形式必须以`--`为前缀，而且支持parameter的三种形式：none、required、optional
* 类型（例如String）。支持将parameter转成特定类型的值。如果不指定，parameter为none类型，存储为true/nil；parameter为required或optional类型，存储为String/nil
* 其他字符串，则认为是对该可选参数的描述。如果参数的描述太长，可以分成几个参数[^9]。
  * 示例代码，见optparse_parameter_Array.rb



举个必填parameter的optional argument的例子，如下

```ruby
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.on('--require LIB', '-r', 'Specify your library', String)
end.parse!(into: options)

p options
p ARGV
```

> 示例代码，见optparse_on_method.rb



#### parameter参数的类型

parameter参数的类型，可以是下面几种

* Bool
* Integer
* String
* Float
* Array



举个例子，如下

```ruby
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.on("-v", "--verbose")
  opts.on("-i", "--integer", Integer, '=integer')
  opts.on("-p", "--path", String, '=path')
  opts.on("-d", "--decimal", Float, '=decimal')

  # Note: take a list of opts (must have a opt at least)
  opts.on("-l", "--list x,y", Array,
          "This command flag takes a comma separated list (without",
          "spaces) of values and turns it into an array. This requires",
          "at least one argument.")
end.parse!(into: options)

p options
p ARGV
```

> 示例代码，见optparse_parameter_type.rb

执行结果，如下

```shell
$ ruby optparse_parameter_type.rb -v -i 3 -p hello -d 3.14 -l 1,2,3,4 1 2 3 4
{:verbose=>true, :integer=>3, :path=>"hello", :decimal=>3.14, :list=>["1", "2", "3", "4"]}
["1", "2", "3", "4"]
```

说明

> 1. on方法的参数，简写参数和非简写参数采用parameter为none的方式，但是补充上'=integer'（或'=[integer]'）表示是required或optional
> 2. `--list x,y`不支持--list 1 2 3 4，只能是--list 1,2,3,4



#### 优化OptionParser的错误提示

OptionParser解析可选参数出错，一般会给出下面提示，如下

```shell
$ ruby optparse_on_method.rb -r
Traceback (most recent call last):
optparse_on_method.rb:6:in `<main>': missing argument: -r (OptionParser::MissingArgument)
```

这个提示和普通CLI程序相比还是不够友好。因此需要捕获这里的异常，并重新给出提示。

```ruby
require 'optparse'

options = {}

begin
  OptionParser.new do |opts|
    opts.on('--require LIB', '-r', 'Specify your library', String)
  end.parse!(into: options)

  p options
  p ARGV
rescue OptionParser::ParseError => e
  puts "#{e.message}"
end
```

> 示例代码，见optparse_pretty_error_prompt.rb

执行结果，如下

```shell
$ ruby optparse_pretty_error_prompt.rb -r
missing argument: -r
```

说明

> OptionParser的异常有好几种，例如OptionParser::MissingArgument，但是可以查看源码发现，它们都是继承自OptionParser::ParseError，所以捕获类型设置OptionParser::ParseError



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

借助shell的`eval`函数和<code>\`command`</code>函数，如下

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



### （2）Ruby代码嵌入到Shell脚本中[^8]

在Shell脚本中使用heredoc语法可以执行内嵌的Ruby代码，例如

```shell
#!/usr/bin/env bash

echo "This is bash!"

/usr/bin/ruby <<EOF

puts 'This is ruby!'

def dump_object(arg)
  puts "[Debug] (#{arg.class}) #{arg.inspect}"
end

dump_object("a")

EOF
```

> 示例见HelloShellScripts的18_ruby_code_within_shell.sh



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





## 7、使用RVM（Ruby Version Manager）



### （1）安装RVM

下载RVM的稳定版本[^5]

```shell
$ \curl -sSL https://get.rvm.io | bash -s stable
```

根据完成的提示，执行下面命令，让rvm命令生效

```shell
$ source /Users/wesley_chen/.rvm/scripts/rvm
```



### （2）rvm命令使用

// TODO 参考evernote







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

[^5]:https://rvm.io/rvm/install

[^6]:https://stackoverflow.com/questions/2463612/passing-multiple-code-blocks-as-arguments-in-ruby
[^7]:https://www.honeybadger.io/blog/capturing-stdout-stderr-from-shell-commands-via-ruby/
[^8]:https://www.devdungeon.com/content/enhanced-shell-scripting-ruby#toc-15

[^9]:https://stackoverflow.com/questions/29229059/how-to-best-wrap-ruby-optparse-code-and-output

[^10]:https://stackoverflow.com/a/6738955

[^11]:https://www.ruby-lang.org/en/documentation/faq/8/
[^12]: https://www.sitepoint.com/ruby-mixins-2/
[^13]:https://medium.com/@leo_hetsch/ruby-modules-include-vs-prepend-vs-extend-f09837a5b073





