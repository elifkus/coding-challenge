package com.github.elifkus.tweetapi

import org.scalatra.test.scalatest._

class TweetApiServletTests extends ScalatraFunSuite {

  addServlet(classOf[TweetApiServlet], "/*")

  test("GET / on TweetApiServlet should return status 200") {
    get("/") {
      status should equal (200)
    }
  }

}
