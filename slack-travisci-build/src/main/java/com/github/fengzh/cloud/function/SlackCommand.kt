package com.github.fengzh.cloud.function

import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.LambdaLogger
import com.amazonaws.services.lambda.runtime.RequestStreamHandler
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent
import com.google.gson.Gson
import okhttp3.*
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.io.PrintStream
import java.net.URLDecoder
import java.util.concurrent.CountDownLatch


class SlackCommand : RequestStreamHandler {

    override fun handleRequest(input: InputStream, output: OutputStream, context: Context) {
        val logger = context.logger
        val slackToken = System.getenv("SLACK_TOKEN")
        val gson = Gson()
        val request = gson.fromJson(input.reader(), APIGatewayProxyRequestEvent::class.java)
        val forms = splitQuery(request.body)
        val response = APIGatewayProxyResponseEvent()
        if (slackToken.isNullOrEmpty() || slackToken != forms["token"]) {
            response.apply {
                statusCode = 403
                headers = mapOf(
                    "Content-Type" to "application/json"
                )
                body = "Invalid token"
            }
            logger.log("Invalid token received")
            gson.toJson(response, PrintStream(output))
        } else {
            logger.log("Start trigger travis ci")
            triggerTravisCi(forms["response_url"], logger)
            response.apply {
                statusCode = 200
            }
            gson.toJson(response, PrintStream(output))
        }
    }

    private fun triggerTravisCi(responseUrl: String?, logger: LambdaLogger) {
        val travisToken = System.getenv("TRAVIS_TOKEN")
        val githubRepo = System.getenv("GITHUB_REPO")
        val branch = System.getenv("BRANCH")?:"master"
        val JSON = MediaType.parse("application/json; charset=utf-8")
        val client = OkHttpClient()

        val body = RequestBody.create(JSON, """
            {
                "request": {
                    "message": "trigger from slack",
                    "branch": "$branch"
                }
            }
        """.trimIndent())
        val request = Request.Builder()
            .url("https://api.travis-ci.org/repo/$githubRepo/requests")
            .header("Authorization", "token $travisToken")
            .header("Travis-API-Version", "3")
            .header("Content-Type", "application/json")
            .header("Accept", "application/json")
            .post(body)
            .build()
        logger.log("Send request to travis ci: ${request.url().url()}")
        val countDown = CountDownLatch(1)
        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                notifyBuildCreated(responseUrl, 500, logger)
                countDown.countDown()
            }

            override fun onResponse(call: Call, response: Response) {
                val respBody = response.body()?.string()
                logger.log("Get response from travis ci with code: ${response.code()}, body: $respBody")
                notifyBuildCreated(responseUrl, response.code(), logger)
                countDown.countDown()
            }
        })
        countDown.await()
    }

    private fun notifyBuildCreated(url: String?, buildCode: Int, logger: LambdaLogger) {
        val JSON = MediaType.parse("application/json; charset=utf-8")
        val client = OkHttpClient()

        val buildMsg = if (buildCode in 200..299) {
            "Command is started"
        } else {
            "Command cannot execute"
        }

        val body = RequestBody.create(JSON, """
            {
                "text": "$buildMsg"
        }
        """.trimIndent())
        val request = Request.Builder()
            .url(url!!)
            .header("Content-Type", "application/json")
            .header("Accept", "application/json")
            .post(body)
            .build()
        logger.log("Send response back to slack: ${request.url().url()}")
        val response = client.newCall(request).execute()
        val respBody = response.body()?.string()
        logger.log("Get slack response: ${response.code()}, body: $respBody")
    }

    fun splitQuery(query: String?): Map<String, String> {
        val queryPairs = mutableMapOf<String, String>()
        val pairs = query?.split("&".toRegex())?.dropLastWhile { it.isEmpty() }?.toTypedArray()
        if (pairs != null) {
            for (pair in pairs) {
                val idx = pair.indexOf("=")
                if (idx != -1) {
                    queryPairs[URLDecoder.decode(pair.substring(0, idx), "UTF-8")] = URLDecoder.decode(pair.substring(idx + 1), "UTF-8")
                }
            }
        }
        return queryPairs
    }

}
