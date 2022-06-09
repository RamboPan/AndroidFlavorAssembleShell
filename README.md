# AndroidFlavorAssembleShell / Android 风味打包脚本

<img src="/docFiles/intro.gif">

### 前言

平常的开发中可能存在因为需要上架不同的商店，或者说需要不同的配置，我们会配置风味去做不同的变体。当打包时如果手动来切换，打不同的包还是比较麻烦。尤其是还需要一些加固或者上传蒲公英平台这样的操作，手工来完成的话是比较费时间，且效率低，所以做了一个脚本自动化。

目前的脚本的简要流程如下，详细流程说明 **流程图** 部分.
- **debug Apk**：打完包之后直接将文件上传到蒲公英。
- **release Apk**：打包完成，再进行对齐，加固，加入渠道标记（**VasDolly**），最后上传蒲公英。

把脚本配置好以后（推荐放在一个公共的服务器上，远程登陆服务器调用，不影响自己编码），运行脚本（当然 Android 环境及运行的相关配置还是得配好），选择需要的打包类型即可，打包过程会发送消息到群聊进行通知（包括上传 Apk 后的链接，方便获取）。可以由开发人员使用，也可以交给测试小伙伴他们去打需要的包。

> 除了上传蒲公英，还增加将所有生成文件压缩为一个整体上传到指定服务器，以解决一些其他场景的需求（测试小伙伴只需要几个关键的包，而运营小伙伴需要所有包）.
>
> 但目前这个方案不太通用，因为暂时没找到一个免费又好用的云空间以及对应接口，特别是文件比较大；另外有些公司只会传到自己的服务器，所以针对这个功能可以参考源修改一下请求和对响应处理。
>
> 脚本在公司内部也用了一段时间，经过了一些迭代后感觉还是挺方便的，但是原计划打磨再好一点再放出来，但是因为一些原因 ... 所以可能会有些小问题，欢迎 👏🏻 提出 issue 与建议进一步优化体验。

---

### 公司的渠道方案

```
├── base
│   ├── 360
│   ├── baidu
│   ├── yingyongbao
|   └-- ...
├── huawei
├── oppo
├── vivo
└── xiaomi
```

- **huawei oppo vivo xiaomi** 接入了对应的支付(这一步使用不同的风味编译)，base 接入的微信支付，所以一共是 5 个。下一步会使用 **VasDolly** 再加入渠道标记，对 **huawei oppo vivo xiaomi** 包分别加入一个标记，对 **base** 包加入不同的标记（如 **360、baidu、yingyongbao**，即都使用 **base** 包产生这些渠道包 ）。

- 所以第一个风味纬度是根据主要渠道区分的，即 **huawei oppo vivo xiaomi base**。

- 第二个风味纬度是根据应用配置的接口是测试环境还是线上环境。我们是这样配置的：**ttest online** (test 在 gradle 中不能直接用，这里多加了一个t)。

- 第三个就是 AS 自带的 **debug  release**，这个是默认加上了。

**所以根据上面的描述，这里的两个纬度配置对应 config.json 中 buildFlavor 数组，第一个参数与第二个参数。**

**buildFlavor 在脚本中默认支持最高 5 个风味纬度，buildFlavor 识别的最大长度为 5.**

```
"buildFlavor":[
    "base xiaomi huawei vivo oppo",
    "ttest online"
],
```

**因为 VasDolly 会针对 huawei oppo vivo xiaomi 几个大的渠道，单独打渠道标记，所以  config.json 中 mainChannel 需要针对这 4 个加入对应风味匹配的渠道标记.(这里我用 book 举例，每个应用的标记名称也各有不同)**

```
"mainChannel":{
    "xiaomi":"book_xiaomi",
    "huawei":"book_huawei",
    "vivo":"book_vivo",
    "oppo":"book_oppo"
},
```

**除了这 4 个大渠道，其他就是通过 base 生成一些小渠道包，那么就在  config.json 中 baseChannel 加入需要的小渠道标记(这里以 360 与 百度举例)。**

```
"baseChannel":"book_360 book_baidu"
```

**Release 时 base 包通过 VasDolly 生成的多个小渠道包，脚本会上传第一个配置的（默认测试只测一个 base 包，即 book_360）**

---

### 流程图

<img src="/docFiles/shellProcessChart.png" width="1020px" height="340px">

---

### 功能

目前已完成的主要功能有如下

| 功能         | 描述                                                         | 截图                                                         |
| ------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 自动拉取代码 | 每次运行自动拉取仓库最新代码并切换到指定分支（git）          | <img src="/docFiles/gitUpdate.png" width="50px" height="50px"> |
| 打包灵活选择 | 根据配置好的文件输出所有的打包类型，可以灵活指定需要的打包类型 | <img src="/docFiles/optionsSelect.png" width="50px" height="50px"> |
| 流程消息通知 | 每个步骤发送消息到指定群聊，方便知道打包流程和结果（飞书）   | <img src="/docFiles/larkNotify.png" width="50px" height="50px"> |
| 上传到蒲公英 | 打包完成上传 Apk 到蒲公英后返回 apk 链接，发送地址消息       | <img src="/docFiles/pgyUrl.png" width="50px" height="50px"> |
| 多种加固选择 | 加入多种加固方式供选择（目前已调试完 爱加密，应用宝，后期加入其他） | <img src="/docFiles/shield.png" width="50px" height="50px"> |
| 重新应用签名 | 加固后需要重新签名，自动重新签名                             | <img src="/docFiles/sign.png" width="50px" height="50px">  |
| 加入压缩对齐 | 调用 zipAlign 对应用进行对齐                                 | <img src="/docFiles/align.png" width="50px" height="50px"> |
| 渠道标记生成 | 使用 VasDolly 生成多个带渠道标记的风味包                     | <img src="/docFiles/vasdolly.png" width="50px" height="50px"> |
| 代码结构解耦 | 各功能单独文件，在主文件调用，如果需要改动或者调整，灵活方便 | <img src="/docFiles/unassemble.png" width="50px" height="50px"> |
| 多进程处理包 | 对初步完成的包进行多进程处理，包括上传、加固、签名、渠道加入等 | <img src="/docFiles/larkNotify.png" width="50px" height="50px"> |

---

### 用法

因为这是 Shell 脚本，所以目前只在 MacOs 与 Linux 上调试，在 Windows 上对应的是批处理，暂时没有兼容。

#### MacOs

- 安装需要用到的库
```
brew install jq
```

- 修改 config.json 文件
```
{
    //项目路径，修改为自己的项目绝对路径
    "projectDir":"/Users/rambopan/Projects/xxx", 
    //远端仓库名，常见为 origin，可以使用 git remote 查看
    "gitRemote":"upstream", 
    //需要打包的分支
    "gitBranch":"xxx", 
    //风味纬度,与数组长度一致，每项中的配置用空格分割
    "buildFavor":[
        "base xiaomi huawei vivo oppo",
        "ttest online"
    ],
    //主渠道，vassdoly 对应的渠道标记
    "mainChannel":{
        "xiaomi":"aaa",
        "huawei":"bbb",
        "vivo":"ccc",
        "oppo":"ddd",
    },
    //base 渠道，vassdoly 对应的渠道标记
    "baseChannel":"kt_360 kt_baidu",
    //需要重新签名，所以需要填入对应 3 个参数
    "key":{
        "keyAlias":"xxx",
        "keyPassword":"xxx",
        "storePassword":"xxx"
    },
    //通知地址，这里示范用的是飞书
    "notifyUrl":"https://open.feishu.cn/open-apis/bot/v2/hook/xxxxx",
    //蒲公英
    "pugongying":{
        "url":"https://upload.pgyer.com/apiv1/app/upload",
        "uKey":"xxx",
        "apiKey":"xxx"
    },
    //整体压缩地址，使用需要根据自己的服务端调整一下
    "uploadZipUrl":"xxx",
    //加固
    "shield":{
        //加固指定方式
        "target":"aijiami",
        //爱加密配置
        "aijiami":{
            "userName":"xxx",
            "type":"xxx",
            "so":"xxx"
        },
        //加固宝配置
        "jiagubao":{
            "userName":"xxx",
            "password":"xxx"
        }
    }
}

```

- 将密钥文件放入 **assets/key/** 中，文件名可以任意，不过需要以 **.jks** 结尾。

- git 远程仓库关联好，确保本地当前状态 clean

```
//确保当前工作区干净
git status

//测试拉取代码正常
git fetch <remote>
```

- 运行脚本
```
# 命令行切换到脚本目录
# sh / bash (或者其他任意 sh 解释器都行，脚本内已指定 bash) 执行 或者 ./ 执行（以下三种都行）
sh run.sh
bash run.sh
./run.sh

# 使用 ./ 第一次需要加入运行权限，如果出现权限问题
chmod ug+x run.sh 
```

#### Linux

// todo 步骤说明,需要处理 MacOs 与 Linux 差异部分

- Linux/Unix data 函数不同
- Linux/Unix zipAlign 二进制文件不同

---

### 待优化的部分

- [ ] 加入其他加固方式
- [ ] 各方法加入执行错误码
- [ ] 流程日志输出文件
- [ ] 多语言（可能 ？）

---

### 感谢

| 名称     | 头像                                                         | 介绍                                                         |
| -------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 十点读书 | <img src="/docFiles/sdiRead.png" width="100px" height="100px"> | 感谢公司小伙伴使用脚本时给予使用反馈优化建议</br>祝小伙伴们前程似锦，江湖再见 |