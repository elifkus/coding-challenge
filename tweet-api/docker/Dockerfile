# Alpine Linux with OpenJDK JRE
FROM openjdk:8-jre-alpine

COPY  target/scala-2.13/TweetAPI-assembly-0.1.0-SNAPSHOT.jar /TweetAPI-assembly-0.1.0-SNAPSHOT.jar

WORKDIR /

ENTRYPOINT ["/usr/bin/java", "-jar",  "/TweetAPI-assembly-0.1.0-SNAPSHOT.jar"]