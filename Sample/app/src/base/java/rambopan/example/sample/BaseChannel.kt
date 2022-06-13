package rambopan.example.sample

/**
 * Author: RamboPan
 * Date: 2022/6/12
 * Describe:Base渠道实现
 */
class BaseChannel : IChannel  {

    override fun getChannelName(): String {
        return "Base"
    }
}