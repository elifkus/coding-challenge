package com.github.elifkus.tweetapi

import java.util.concurrent.Future

import com.github.elifkus.tweetapi.models._
import org.scalatra._
import org.scalatra.CorsSupport
import org.json4s.{DefaultFormats, Formats}
import org.json4s.jackson.Serialization.{read, write}
import org.scalatra.json._
import sttp.client3._
import sttp.client3.json4s._

class TweetApiServlet extends ScalatraServlet with JacksonJsonSupport with CorsSupport {
  protected implicit val jsonFormats: Formats = DefaultFormats + new SentimentSerializer
  protected implicit val serialization = org.json4s.jackson.Serialization

  before() {
    contentType = formats("json")
  }
  options("/*"){
    response.setHeader(
      "Access-Control-Allow-Headers", request.getHeader("Access-Control-Request-Headers"));
  }
  get("/") {
    "{\"status\": \"ok\"}"
  }

  post("/api/analysis") {
    println("/api/analysis called")
    //val tweetInput = parsedBody.extract[TweetInput]
    println("Input: " + request.body)
    val tweetInput = read[TweetInput](request.body)
    printlnt(tweetInput.content)
    askForToxicity(tweetInput) match {
      case Left(errorOutput) => {
        errorOutput
      }
      case Right(sentimentAnalysisResult) => {
        println(sentimentAnalysisResult)
        extractApiOutput(tweetInput, sentimentAnalysisResult)
      }
    }

  }

  def askForToxicity(tweetInput: TweetInput): Either[String, List[SentimentAnalysisOutput]] = {
    val payload = SentimentAnalysisInput(Array(tweetInput.content), 0.9)
    val request = basicRequest.post(uri"http://localhost:9000/toxicity")
      .body(write(payload))
      .contentType("application/json")
      .response(asJson[List[SentimentAnalysisOutput]])

    val backend = HttpURLConnectionBackend()
    val response: Response[Either[ResponseException[String, Exception], List[SentimentAnalysisOutput]]] = request.send(backend)

    response.body match {
      case Left(responseException) => {
        println("ResponseException:" + responseException)
        Left("{\"error\": \"Error received\"}")
      }
      case Right(output) => Right(output)
    }
  }

  def extractApiOutput(input: TweetInput, sentimentOutputList: List[SentimentAnalysisOutput]): Analysis = {
    val sentimentOutput = sentimentOutputList.filter(_.label.equals(input.content)).head

    val analysis = new Analysis(sentimentOutput.sentiment.identityAttack.sentimentmatch,
      sentimentOutput.sentiment.insult.sentimentmatch,
      sentimentOutput.sentiment.obscene.sentimentmatch,
      sentimentOutput.sentiment.severeToxicity.sentimentmatch,
      sentimentOutput.sentiment.sexualExplicit.sentimentmatch,
      sentimentOutput.sentiment.threat.sentimentmatch,
      sentimentOutput.sentiment.toxicity.sentimentmatch
    )
    analysis
  }
}


