#  使用audioUnit播放本地视频【最简单的连接】
### 相关类
1. audioSession ：配置categator/rate/active等 和 相关事件监控
2. audioPlay:
    - AuGraph
    - AUNode
    - AudioUnit（一个kAudioUnitSubType_RemoteIO,一个kAudioUnitSubType_AudioFilePlayer）

### audioPlay初始化过程
1. 初始化 graph
2. 创建node描述，把node绑定到graph中
3. 打开 graph 以实例化node 并绑定unit
4. 设置unit参数 AudioStreamBasicDescription（音频类型、流的相关属性frame/packet/channel/rate等）
5. 根据流的路线连接node [复杂实现，建立多个unit 对音频进行处理、分离器、混音器等]
6. 初始化graph 
7. 根据文件路径配置 file与playUnit读取策略
8. 播放控制：开始和暂停

