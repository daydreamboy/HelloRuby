# Ruby Notes

[TOC]



## 1、RDoc语法

[RDoc](https://ruby.github.io/rdoc/)是Ruby代码的注释生成文档的工具，包括rdoc和ri两个工具。这个[Cheatsheet](https://devhints.io/rdoc)提供RDoc支持注释形式。





## 2、常用Ruby函数



### system

格式：**system([env,] command... [,options]) → true, false or nil**

作用：产生一个子shell，执行command

说明：

返回nil，表示命令执行出错

> system returns `true` if the command gives zero exit status, `false` for non zero exit status. Returns `nil` if command execution fails. An error status is available in `$?`.





## 1、gem命令使用



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





## 2、rvm命令使用







## 3、Ruby语法



## 4、常用Gem



| gem名称              | 作用                          |
| -------------------- | ----------------------------- |
| update_xcode_plugins | 安装Xcode Plugin后重签名Xcode |

