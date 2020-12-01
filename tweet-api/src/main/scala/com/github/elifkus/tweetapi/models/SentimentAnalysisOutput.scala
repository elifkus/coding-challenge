package com.github.elifkus.tweetapi.models

import org.json4s.{CustomSerializer, JField, JObject, JString, JBool, JDouble}

case class SentimentAnalysisOutput(
                                    label: String,
                                    sentiment: SentimentReport
                                   )

case class SentimentReport(
                            identityAttack: Option[Sentiment],
                            insult: Option[Sentiment],
                            obscene: Option[Sentiment],
                            severeToxicity: Option[Sentiment],
                            sexualExplicit: Option[Sentiment],
                            threat: Option[Sentiment],
                            toxicity: Option[Sentiment]
                          )

case class Sentiment(
                    sentimentmatch: Boolean,
                    probability0: Double,
                    probability1: Double)


class SentimentSerializer extends CustomSerializer[Sentiment](format => (
  {
    case JObject(
      JField("match", JBool(sentimentmatch))
        :: JField("probability0", JDouble(probability0))
        :: JField("probability1", JDouble(probability1))
        :: Nil
    ) => Sentiment(sentimentmatch, probability0, probability1)
  },
  {
    case sentiment: Sentiment =>
      JObject(
        JField("match", JBool(sentiment.sentimentmatch))
          :: JField("probability0", JDouble(sentiment.probability0))
          :: JField("probability1", JDouble(sentiment.probability1))
          :: Nil
      )
  }
))

