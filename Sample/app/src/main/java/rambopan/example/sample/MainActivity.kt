package rambopan.example.sample

import android.annotation.SuppressLint
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.TextView

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