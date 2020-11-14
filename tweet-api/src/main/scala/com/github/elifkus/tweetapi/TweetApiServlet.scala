package com.github.elifkus.tweetapi

import com.github.elifkus.tweetapi.models.Analysis
import org.scalatra._
import org.json4s.{DefaultFormats, Formats}
import org.scalatra.json._
import sttp.client3._


class TweetApiServlet extends ScalatraServlet with JacksonJsonSupport {
  protected implicit val jsonFormats: Formats = DefaultFormats

  get("/") {
    "{\"status\": \"ok\"}"
  }

  get("/api/analysis") {
    println("/api/analysis called")
    val signup = Some("yes")

    val request = basicRequest.post(uri"http://localhost:9000/toxicity")
      .body("""{"sentences": ["This is a bad sentence!"],"threshold": 0.9}""")
      .contentType("application/json")

    val backend = HttpURLConnectionBackend()
    val response = request.send(backend)

    response.body
  }

  before() {
    contentType = formats("json")
  }

}

