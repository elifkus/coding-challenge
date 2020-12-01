package com.github.elifkus.tweetapi

import org.scalatra.test.scalatest._
import com.github.elifkus.tweetapi.TweetApiServlet
import com.github.elifkus.tweetapi.models._

class TweetApiServletTests extends ScalatraFunSuite {

  addServlet(classOf[TweetApiServlet], "/*")

  test("GET / on TweetApiServlet should return status 200") {
    get("/") {
      status should equal (200)
    }
  }

  test("extractApiOutput extracts content") {
    val identityAttack = Sentiment(true, 0.98, 0.01)
    val insult = Sentiment(false, 0.50, 0.01)
    val obscene = Sentiment(true, 0.98, 0.01)
    val severeToxicity = Sentiment(false, 0.50, 0.01)
    val sexualExplicit = Sentiment(true, 0.98, 0.01)
    val threat = Sentiment(true, 0.98, 0.01)
    val toxicity = Sentiment(true, 0.98, 0.01)

    val sentimentReport = SentimentReport(Some(identityAttack),
                                          Some(insult),
                                          Some(obscene),
                                          Some(severeToxicity),
                                          Some(sexualExplicit),
                                          Some(threat),
                                          Some(toxicity))
    
    val sentimentAnalysisOutput = SentimentAnalysisOutput("Horrible sentence", sentimentReport)
    val resultList = List(sentimentAnalysisOutput)

    val tweetInput = TweetInput("Horrible sentence")
    val servlet = new TweetApiServlet()
    val analysis = servlet.extractApiOutput(tweetInput, resultList)

    assert(Some(obscene.sentimentmatch) === analysis.obscene)
    assert(Some(insult.sentimentmatch) === analysis.insult)
  }

  test("extractApiOutput extracts content when one field misses") {
    val identityAttack = Sentiment(true, 0.98, 0.01)
    val obscene = Sentiment(true, 0.98, 0.01)
    val severeToxicity = Sentiment(false, 0.50, 0.01)
    val sexualExplicit = Sentiment(true, 0.98, 0.01)
    val threat = Sentiment(true, 0.98, 0.01)
    val toxicity = Sentiment(true, 0.98, 0.01)

    val sentimentReport = SentimentReport(Some(identityAttack),
                                              None,
                                              Some(obscene),
                                              Some(severeToxicity),
                                              Some(sexualExplicit),
                                              Some(threat),
                                              Some(toxicity))
    
    val sentimentAnalysisOutput = SentimentAnalysisOutput("Horrible sentence", sentimentReport)
    val resultList = List(sentimentAnalysisOutput)

    val tweetInput = TweetInput("Horrible sentence")
    val servlet = new TweetApiServlet()
    val analysis = servlet.extractApiOutput(tweetInput, resultList)

    assert(Some(obscene.sentimentmatch) === analysis.obscene)
    assert(None === analysis.insult)

  }

}
