# AndroidFlavorAssembleShell / Android 风味打包脚本

<img src="/docFiles/images/version.png" width="160px" height="32px">

### 前言

​		平常的开发中可能存在因为需要上架不同的商店，或者说需要不同的配置，我们会配置风味去生成不同的变体 Apk 。（下文将生成 Apk 简称为打包）

​		当打包时如果手动来切换，打几个类型或者打不同类型还是比较麻烦。尤其是还需要一些加固或者上传蒲公英平台这样的操作，手工来完成的话是比较费时间，且效率低，所以做了一个脚本自动化。

​		这个脚本是检测可以打包的类型，列出所有类型，通过选择自己需要打包类型生成所有 Apk 文件。选择的方式包括：

- 通过 d / r 选择仅打 debug / release 包
- 通过数字选择需要的打包类型，例如 0 2 4
- 通过文字过滤选择需要打包类型，比如 Online_Release
- 通过回车选择所有打包类型

  一句话总结这个脚本的作用：**让打包更灵活、自动化** 



<img src="/docFiles/images/intro.gif">



> 注：脚本在公司内部也用了一段时间，经过了一些迭代后感觉还是挺方便的，所以决定开源，原计划打磨好一点再放出来，但是因为一些原因 ... 
>
> 暂还没有接入配置异常处理，使用中可能会有些小问题，请跟着说明调试一下。
>
> 欢迎 👏🏻 提出 issue 与建议进一步优化体验，如果觉得不错的话，麻烦点一个 ⭐️ 表示支持。

---



### 说明

#### 流程图

<img src="/docFiles/images/shellProcessChart.png" width="1020px" height="340px">



#### 打包类型区别
- **debug Apk**：打完包之后直接将文件上传到蒲公英。
- **release Apk**：打包完成，再进行对齐，加固，加入渠道标记（**VasDolly**），最后上传蒲公英。



#### 流程说明

​		把脚本配置好以后（推荐放在一个公共的服务器上，远程登陆服务器调用，不影响自己编码）。

​		运行脚本（当然 Android 环境及运行的相关配置还是得配好），选择需要的打包类型即可。

​		打包过程会发送消息到群聊进行通知（通知用的是飞书的接口，发送的消息主要是打包流程走到哪一步了，如果上传 Apk 到蒲公英后会把链接发出来，方便获取，如果不是飞书的话可以找对应办公软件接口调一下）。

​		可以由开发人员使用，也可以交给测试小伙伴他们去打需要的包。

> 注：除了上传蒲公英，还增加将所有生成文件压缩为一个整体上传到指定服务器，以解决一些其他场景的需求（测试小伙伴只需要几个关键的包，而运营小伙伴需要所有包）.
>
> 但目前这个方案不太通用，因为暂时没找到一个免费又好用的云空间以及对应接口，特别是文件比较大；另外有些公司只会传到自己的服务器，所以针对这个功能可以参考源码修改一下请求和对响应处理。



#### 公司的渠道方案

##### Flavor 风味配置

```
channel             host                 buildType              gradleTask
├── base            ├── ttest            ├── debug              ├── baseTtestDebug
├── huawei          └── online           └── release            ├── baseTtestRelease
├── oppo                                                        ├── baseOnlineDebug
└── vivo                                                        ├── baseOnlineRelease
                                                                ├── huaweiTtestDebug
                                                                ├── huaweiTtestRelease
                                                                ├── huaweiOnlineDebug
                                                                ├── huaweiOnlineRelease
                                                                ├── oppoTtestDebug
                                                                ├── oppoTtestRelease
                                                                ├── oppoOnlineDebug
                                                                ├── oppoOnlineRelease
                                                                ├── vivoTtestDebug
                                                                ├── vivoTtestRelease
                                                                ├── vivoOnlineDebug
                                                                └── vivoOnlineRelease
```



- 第一个风味度（**channel**）是根据是否有合作的登录、支付渠道区分的。
- 第二个风味度（**host**）是根据应用配置的接口是测试环境还是线上环境。我们是这样配置的：**ttest online** (test 在 gradle 中不能直接用，这里多加了一个 t)。
- 第三个风味度（**buildType**）就是 gradle 默认配置了。

> 提一句：没有 **xiaomi** 是因为小米的联运效果不理想，取消了联运，所以小米也用的 base 包。



**根据上面的设置，一共可以组合出 16 个 apk 对应的 gradle 任务。这里的前两个风味度配置对应 config.json 中 buildFlavor 数组，第一个参数与第二个参数，每个风味度的参数之间以空格分割。**

**buildFlavor 在脚本中默认支持最高 5 个风味纬度（buildType 不算在内），即 buildFlavor 数组长度最大为 5（这个值可以修改，只是我认为普通情况不需要这么支持这么高）.**

```json
"buildFlavor":[
    "base huawei vivo oppo",
    "ttest online"
],
```



##### VasDolly 渠道细化(可选，不需要可跳过)

​		因为 **base** 包一般是不集成手机品牌的登录，支付就是微信和支付宝，但是会上传不同的渠道。（如 **360、baidu、yingyongbao**）

​		所以在区分这些渠道的时候，使用 **VasDolly** 再加入渠道标记，对 **base** 包加入不同的标记（如 **360、baidu、yingyongbao**，即都使用 **base** 包产生这些渠道包 ）。之前的 **huawei oppo vivo** 包也需要分别加入一个各自的标记，这样和 **base** 包保持一致，都可以通过 **VasDolly** 进行渠道区分。

​		通过 **VasDolly** 对 **huawei oppo vivo** 几个大的渠道，单独打渠道标记，所以  **config.json** 中 **mainChannel** 需要针对这 3 个加入对应风味匹配的渠道标记。(这里我用 book 举例，取名根据自己的应用需求)

```json
"mainChannel":{
    "huawei":"book_huawei",
    "vivo":"book_vivo",
    "oppo":"book_oppo"
},
```

​		除了这 3 个大渠道，其他就是通过 **base** 生成一些其他渠道包，那么就在  **config.json** 中 **baseChannel** 加入需要的小渠道标记(这里以 **360** 与 **baidu** 举例)。

```json
"baseChannel":"book_360 book_baidu"
```

​		打 **Release** 包时 **base** 包通过 **VasDolly** 生成的多个小渠道包，脚本会上传第一个配置的（即 **book_360**，默认测试只需要测一个 **base** 包）


---



### 功能

目前已完成的主要功能有如下

| 功能         | 描述                                                         | 截图                                                         |
| ------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 自动拉取代码 | 每次运行自动拉取仓库最新代码并切换到指定分支（git）          | <img src="/docFiles/images/gitUpdate.png" width="50px" height="50px"> |
| 打包灵活选择 | 根据配置好的文件输出所有的打包类型，可以灵活指定需要的打包类型 | <img src="/docFiles/images/optionsSelect.png" width="50px" height="50px"> |
| 流程消息通知 | 每个步骤发送消息到指定群聊，方便知道打包流程和结果（飞书）   | <img src="/docFiles/images/larkNotify.png" width="50px" height="50px"> |
| 上传到蒲公英 | 打包完成上传 Apk 到蒲公英后返回 apk 链接，发送地址消息       | <img src="/docFiles/images/pgyUrl.png" width="50px" height="50px"> |
| 多种加固选择 | 加入多种加固方式供选择（目前已调试完 爱加密，应用宝，后期加入其他） | <img src="/docFiles/images/shield.png" width="50px" height="50px"> |
| 重新应用签名 | 加固后需要重新签名，自动重新签名                             | <img src="/docFiles/images/sign.png" width="50px" height="50px">  |
| 加入压缩对齐 | 调用 zipAlign 对应用进行对齐                                 | <img src="/docFiles/images/align.png" width="50px" height="50px"> |
| 渠道标记生成 | 使用 VasDolly 生成多个带渠道标记的风味包                     | <img src="/docFiles/images/vasdolly.png" width="50px" height="50px"> |
| 代码结构解耦 | 各功能单独文件，在主文件调用，如果需要改动或者调整，灵活方便 | <img src="/docFiles/images/unassemble.png" width="50px" height="50px"> |
| 多进程处理包 | 对初步完成的包进行多进程处理，包括上传、加固、签名、渠道加入等 | <img src="/docFiles/images/larkNotify.png" width="50px" height="50px"> |

---



### 用法

因为这是 **Shell** 脚本，所以目前只在 **MacOs** 与 **Linux** 上使用，**Windows** 上暂时没有考虑。

[这里拿 Sample 工程说明，内容较长，请移步这里](/docFiles/sampleIntroAndShellUseage.md)

---



### 待优化的部分

- [ ] 加入其他加固方式
- [ ] 各方法加入执行错误码
- [ ] 流程日志输出文件，且保留天数可以设置
- [ ] 多语言（可能 ？）

---



### 感谢

| 名称     | 头像                                                         | 介绍                                                         |
| -------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 十点读书 | <img src="/docFiles/images/sdiRead.png" width="100px" height="100px"> | 感谢公司小伙伴使用脚本时给予使用反馈及优化建议</br>祝小伙伴们前程似锦，江湖再见 |