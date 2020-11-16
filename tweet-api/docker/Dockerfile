# Alpine Linux with OpenJDK JRE
FROM openjdk:8-jre-alpine
# copy WAR into image

COPY  target/scala-2.13/TweetAPI-assembly-0.1.0-SNAPSHOT.jar /TweetAPI-assembly-0.1.0-SNAPSHOT.jar
# run application with this command line 
CMD ["/usr/bin/java", "-jar",  "/TweetAPI-assembly-0.1.0-SNAPSHOT.jar"]