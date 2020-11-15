package com.github.elifkus.tweetapi.SerializationTests;

import org.scalatest.FunSuite;
import com.github.elifkus.tweetapi.models.{Sentiment, SentimentSerializer}
import org.json4s.jackson.Serialization.{read, write}

class SentimentAnalysisOutputTests extends FunSuite {
    implicit val formats = org.json4s.DefaultFormats + new SentimentSerializer

    test("the Sentiment values are set correctly in constructor") {
        val s = Sentiment(true, 0.98, 0.01)
        assert(s.sentimentmatch == true)
        assert(s.probability0 == 0.98)
        assert(s.probability1 == 0.01)
    }

    test("the Sentiment serializes and deserializes correctly") {
        println("Serializer test called")
        val sentiment = Sentiment(true, 0.98, 0.01)
        val serialized = write(sentiment)
        println("serialized")
        println(serialized)
        val deserialized = read[Sentiment](serialized)
        assert(deserialized === sentiment)
    }
}
