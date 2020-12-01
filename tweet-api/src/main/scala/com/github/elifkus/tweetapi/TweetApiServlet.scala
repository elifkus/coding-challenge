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
import sttp.model.Uri

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
    val tweetInput = read[TweetInput](request.body)

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
    val serviceUrl = if(System.getenv("SERVICE_URL") != null) System.getenv("SERVICE_URL") else "http://localhost:9000"

    val request = basicRequest.post(uri"$serviceUrl/toxicity")
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
    
    val analysis = new Analysis()
    
    analysis.identityAttack = sentimentOutput.sentiment.identityAttack match {
      case Some(item) =>  Some(item.sentimentmatch)
      case None => None
    }

    analysis.insult = sentimentOutput.sentiment.insult match {
      case Some(item) =>  Some(item.sentimentmatch)
      case None => None
    }

    analysis.obscene = sentimentOutput.sentiment.obscene match {
      case Some(item) =>  Some(item.sentimentmatch)
      case None => None
    }

    analysis.severeToxicity = sentimentOutput.sentiment.severeToxicity match {
      case Some(item) =>  Some(item.sentimentmatch)
      case None => None
    }

    analysis.sexualExplicit = sentimentOutput.sentiment.sexualExplicit match {
      case Some(item) =>  Some(item.sentimentmatch)
      case None => None
    }

    analysis.threat = sentimentOutput.sentiment.threat match {
      case Some(item) =>  Some(item.sentimentmatch)
      case None => None
    }

    analysis.toxicity = sentimentOutput.sentiment.toxicity match {
      case Some(item) =>  Some(item.sentimentmatch)
      case None => None
    }
    analysis
  }
}


