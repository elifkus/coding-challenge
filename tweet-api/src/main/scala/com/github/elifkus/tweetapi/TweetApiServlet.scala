package com.github.elifkus.tweetapi

import com.github.elifkus.tweetapi.models.Analysis
import org.scalatra._
import org.json4s.{DefaultFormats, Formats}
import org.scalatra.json._

class TweetApiServlet extends ScalatraServlet with JacksonJsonSupport {
  protected implicit val jsonFormats: Formats = DefaultFormats

  get("/") {
    "{\"status\": \"ok\"}"
  }

  get("/api/analysis") {
    AnalysisData.oneAnalysis
  }

  before() {
    contentType = formats("json")
  }

}


object AnalysisData {

  /**
   * Some fake Analysis data so we can simulate retrievals.
   */
  var oneAnalysis = Analysis(true, true, true, true, true, true, true)
}