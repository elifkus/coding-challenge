package com.github.elifkus.tweetapi

import com.github.elifkus.tweetapi.models.Analysis
import com.github.elifkus.tweetapi.models.SentimentAnalysisInput
import com.github.elifkus.tweetapi.models.TweetInput
import org.scalatra._
import org.json4s.{DefaultFormats, Formats}
import org.json4s.jackson.Serialization.{read, write}
import org.scalatra.json._
import sttp.client3._

class TweetApiServlet extends ScalatraServlet with JacksonJsonSupport {
  protected implicit val jsonFormats: Formats = DefaultFormats
  protected implicit val serialization = org.json4s.jackson.Serialization
  //protected implicit val formats = org.json4s.DefaultFormats

  before() {
    contentType = formats("json")
  }

  get("/") {
    "{\"status\": \"ok\"}"
  }


  post("/api/analysis") {
    println("/api/analysis called")
    val tweetInput = parsedBody.extract[TweetInput]
    askForToxicity(tweetInput)
  }

  def askForToxicity(tweetInput: TweetInput): Either[String,String] = {
    val payload = SentimentAnalysisInput(Array(tweetInput.content), 0.9)
    val request = basicRequest.post(uri"http://localhost:9000/toxicity")
      .body(write(payload))
      .contentType("application/json")

    val backend = HttpURLConnectionBackend()
    val response = request.send(backend)

    response.body
  }


}

