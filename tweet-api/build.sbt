val ScalatraVersion = "2.7.0"

organization := "com.github.elifkus"

name := "Tweet API"

version := "0.1.0-SNAPSHOT"

scalaVersion := "2.13.1"

resolvers += Classpaths.typesafeReleases

libraryDependencies ++= Seq(
  "org.scalatra" %% "scalatra" % ScalatraVersion,
  "org.scalatra" %% "scalatra-json" % "2.7.0",
  "org.json4s"   %% "json4s-jackson" % "3.7.0-M7",
  "org.scalatra" %% "scalatra-scalatest" % ScalatraVersion % "test",
  "com.softwaremill.sttp.client3" %% "core" % "3.0.0-RC9",
  "com.softwaremill.sttp.client3" %% "json4s" % "3.0.0-RC9",
  "ch.qos.logback" % "logback-classic" % "1.2.3" % "runtime",
  "org.eclipse.jetty" % "jetty-webapp" % "9.4.28.v20200408" % "container",
  "javax.servlet" % "javax.servlet-api" % "3.1.0" % "provided",
  "org.scalatest" %% "scalatest" % "3.0.8" % Test
)



enablePlugins(SbtTwirl)
enablePlugins(ScalatraPlugin)
