package com.github.elifkus.tweetapi

import org.scalatra._

class TweetApiServlet extends ScalatraServlet {

  get("/") {
    views.html.hello()
  }

  get("/api/analysis") {
    views.html.hello()
  }


}
