## Sample 工程介绍及脚本使用说明



### Sample 说明

#### 效果展示

工程很简单，在主页面加入三个 TextView ，一个是显示的当前的渠道，一个显示的当前的网络环境，一个是显示 **debug** 还是 **release**。xml 代码很简单，我就不贴了。

```kotlin
class MainActivity : AppCompatActivity() {
    @SuppressLint("SetTextI18n")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        findViewById<TextView>(R.id.tvChannel).text = "Channel:${ChannelManager.channel.getChannelName()}"
        findViewById<TextView>(R.id.tvHost).text = "Host:${BuildConfig.HOST_ENV}"
	      findViewById<TextView>(R.id.tvBuildType).text = "BUILD_TYPE:${BuildConfig.BUILD_TYPE}"
    }
}
```

主页面显示渠道和网路环境会根据打不同包而进行不同的编译，生成不同的变体包。



<img src="/docFiles/images/flavorScreen.png" width="1024px" height="502px">



#### 风味配置

既然要通过脚本打不同的变体包，那肯定是要先配置上风味，能打不同的变体包，再去设置脚本，所以这里先把风味配置讲一下，**buildType** 是 gradle 文件中已经默认配置了，所以这里不考虑。

打开 **app/build.gradle** 在 **android** 层中可以看到 **productFlavors** 这项。

```gradle
		productFlavors {
				// 声明两个风味度
        flavorDimensions 'channel', 'host'

        // channel的值
        huawei {
            dimension 'channel'
        }

        oppo {
            dimension 'channel'
        }

        base {
            dimension 'channel'
        }

        // host的值
        online {
            dimension 'host'
            // 在 BuildConfig 中加入一个变量 HOST_ENV = "https://online.api.com"
            buildConfigField('String', 'HOST_ENV', '"https://online.api.com"')
        }

        ttest { // 这不能直接使用 test，所以多加了一个 t
            dimension 'host'
            // 在 BuildConfig 中加入一个变量 HOST_ENV = "https://test.api.com"
            buildConfigField('String', 'HOST_ENV', '"https://test.api.com"')
        }
    }
```

按照说明文档中，这里也是演示的 2 个风味度。

- **channel**

  这里选择声明了 3 种类型 （huawei oppo base），这里演示的是通过相同的接口，在编译时用不同的实现去调用相同的代码，达到不同的效果。

  在 java/main 级目录，新建 3 个同级的目录（huawei oppo base），再把对应的实现渠道的代码放在各的目录下，先放图说明下，再简单贴下代码，很简单，一看就懂。

  <image buildVariantSelect>

  

  ```
  // main/java 中
  /**
   * Author: RamboPan
   * Date: 2022/6/12
   * Describe:渠道统一接口
   */
  interface IChannel {
  
      fun getChannelName(): String
  }
  
  // huawei/java 华为渠道的实现代码
  object ChannelManager {
  
      val channel: IChannel = HuaweiChannel()
  }
  class HuaweiChannel : IChannel  {
  
      override fun getChannelName(): String {
          return "Huawei"
      }
  }
  
  oppo 与 base 也类似.
  val channel: IChannel = XXChannel() 
  XXChannel.getChannelName() 返回对应的字符。
  这里就不贴出来了。
  ```



- **host**

  这里选择声明了 2 种类型 （ttest online），这里演示的是通过 gradle 加入一个变量设置，在编译时产生的 BuildConfig 类中对应不同的值。

  （这个类有时标红是因为，这个是编译后产生的，如果第一次运行，运行完应该是可以点击跳转到对应的 BuildConfig 类，看到加入的 HOST_ENV 变量的，这里演示的 ttest 情况下）

  ```
  package rambopan.example.sample;
  
  public final class BuildConfig {
    public static final boolean DEBUG = Boolean.parseBoolean("true");
    public static final String APPLICATION_ID = "rambopan.example.sample";
    public static final String BUILD_TYPE = "debug";
    public static final String FLAVOR = "oppoTtest";
    public static final String FLAVOR_channel = "oppo";
    public static final String FLAVOR_host = "ttest";
    public static final int VERSION_CODE = 1;
    public static final String VERSION_NAME = "1.0";
    // Field from product flavor: ttest
    public static final String HOST_ENV = "https://test.api.com";
  }
  ```

通过以上步骤就已经在项目中配好了这些风味，接下来可以在左下角 Build Variants 中可以选择不同的变体运行，就可以看到在不同风味下 App 运行时显示不同的信息，如之前的图演示的，这就满足了我们的需求。

---



### Shell 脚本用法说明

#### 用法

​		大部分步骤差不多，不一样的会单独列出来，先列详细步骤，后面跟一个示范操作。

- 安装需要用到的库（MacOS / Linux）

  ```shell
  # 打开命令行，输入下面一行并回车
  brew install jq
  
  # 等命令结束后，尝试输入 jq 并回撤，如果以下类似提示就是可以了。
  jq - commandline JSON processor [version 1.6]
  
  Usage:	jq [options] <jq filter> [file...]
  	jq [options] --args <jq filter> [strings...]
  	jq [options] --jsonargs <jq filter> [JSON_TEXTS...]
  ```

  下面这个只需要 Linux 安装.

  ```shell
  # 打开命令行，输入下面一行并回车
  sudo apt install zipalign
  
  # 等命令结束后，尝试输入 zipalign ，如果以下类似提示就是可以了。
  Zip alignment utility Copyright (C) 2009 The Android Open Source Project
  
  Usage: zipalign [-f] [-p] [-v] [-z] <align> infile.zip outfile.zip zipalign -c [-p] [-v] <align> infile.zip
  
  <align>: alignment in bytes, e.g. '4' provides 32-bit alignment -c: check alignment only (does not modify file) -f: overwrite existing outfile.zip -p: memory page alignment for stored shared object files -v: verbose output -z: recompress using Zopfli
  ```

  

- 修改 config.json 文件（MacOS / Linux）

  ```json
  {
      //项目路径，修改为自己 Android 项目绝对路径，这里改成我测试项目 Sample 的地址吧
      "projectDir":"/Users/rambopan/Projects/xxx/Sample",
      
      //远端仓库名，常见为 origin，可以使用 git remote 查看
      //这里因为示范的代码不需要更新，所以这里选空，不走 git 更新
      "gitRemote":"",
      
      //需要打包的分支
      //这里因为示范的代码不需要更新，所以这里选空，不走 git 更新
      "gitBranch":"",
      
      //风味度,与数组长度一致，每项中的配置用空格分割
      "buildFlavor":[
          "base huawei oppo",
          "ttest online"
      ],
      
      //主渠道，vassdoly 对应的渠道标记
      //不需要可以设置为 {} 空参数对象
      "mainChannel":{
          "huawei":"bbb",
          "vivo":"ccc",
          "oppo":"ddd",
      },
      
      //base 渠道，vassdoly 对应的渠道标记
      //不需要可以设置为 "" 空字符对象
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
      
      //整体文件压缩后上传地址，使用需要根据自己的服务端调整一下
      "uploadZipUrl":"",
      
      //加固
      "shield":{
          //加固指定方式
          //如果不需要的话，target 设置为 "" 作为空字符
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



- 放入秘钥（MacOS / Linux）

  将密钥文件放入 **assets/key/** 中，文件名可以任意，不过需要以 **.jks** 结尾。



- git 远程仓库关联好，确保本地当前状态干净。（MacOS / Linux）

  ```shell
  # 确保当前工作区干净
  git status
  
  # 测试拉取代码正常
  git fetch origin (或者其他远程仓库名)
  ```



- 如果是 Linux 使用，修改一点源码（Linux）
  因为 Linux 与 MacOS 有小部分区别，不过也很简单。

  ```shell
  # 第一处修改，date 函数调整一下
  # 打开 lib/log.sh 将 timStamp 方法 1) 时逻辑修改一下，即把这行替换一下。
  # 源代码
  echo $(date -r $1 '+%Y-%m-%d %H:%M:%S');;
  # 改为如下
  echo $(date -d @$1 '+%Y-%m-%d %H:%M:%S');;
  ```

  ```shell
  # 第二处修改，zipalign 方法替换一下
  # 打开 lib/align.sh 将 funAlign 方法中这一行替换下。
  # 源代码
  $zipAlignPath -v -p 4 $1 $2
  # 改为如下
  zipAlign -v -p 4 $1 $2
  # 改后第一行（local zipalignPath="$curDir/assets/align/zipalign"）可以删掉也可以不删，不影响
  ```



- 运行脚本

  ```shell
  # 命令行切换到脚本目录
  cd xxx
  
  # sh / bash 执行 (或者其他任意 sh 解释器都行，脚本内已指定 bash)
  # 或者 ./ 执行
  
  sh run.sh
  bash run.sh
  ./run.sh
  
  # 使用 ./ 第一次需要加入执行权限
  chmod ug+x run.sh
  ```



#### 示范

 - 开启命令行，克隆工程

   （准备工作还是要参考上面做一下哈，这里跳过了）

   我放桌面进行演示，然后修改 config.json，主要是修改项目的地址 projectDir，这里需要需要输入的是 Android 工程 Sample 路径。

   <img src="/docFiles/images/sampleShowStep_1.png">

   

 - 进入项目目录，输入如下命令行

   ```
    sh run.sh
   ```

   可以看到先打印了当前配置 json 参数，中间有一步通过项目 git 拉取代码并切换到指定分支，因为没有配置，所以这里跳过了。接下来是输出当前可以打包的任务选择。

   <img src="/docFiles/images/sampleShowStep_2.png">

   

 - 选择需要打包类型

   可以看到目前有多种方式可以选择，为了演示打几个包，按照文字过滤这种方式吧，输入 **Ttest_Debug。**（这里输入 0 2 4 也是一样的效果，数字选择了这 3 个包。

   接下来会询问是否上传指定服务器，目前这个建议根据自己公司服务端修改下对应的源码  lib/upload.sh/funUploadZipApksToServer 方法，这里直接回车，会显示所有过滤出的任务，这里确认一下我们需要打的包对不对。

   <img src="/docFiles/images/sampleShowStep_3.png">
   	

 - 稍等片刻，可以看到包已经打好了。

​	  <img src="/docFiles/images/sampleShowStep_4.png">




​	示范了 debug 包，再来简单演示 release 包，这里的步骤包括 加固、对齐、再次签名、VasDolly 几部分。

> 这里这个简单的项目，没有 so ，爱加密加固时需要输入 so ，没有输入所以这里演示爱加密是不会加固的。

  - 同样先修改配置.

    修改的是 mainChannel 与 baseChannel 中的值（演示 VasDolly），修改签名的有关设置，将秘钥放入 assets/key/ 下，输入 aijiami 有关设置，shield/target 输入 aijiami 表示选择爱加密这种加固方式。

​	  <img src="/docFiles/images/sampleShowStep_5.png">



  - 这里输入 Online_Release，可以看到筛选出需要打包的类型。

​	  <img src="/docFiles/images/sampleShowStep_6.png">



  - 这里稍微等待一下，可以看到所有应用包了，因为上传压缩选项时选了 y，所以这里会压缩一个总的文件。

​	  <img src="/docFiles/images/sampleShowStep_7.png">

