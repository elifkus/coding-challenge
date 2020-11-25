# Alpine Linux with OpenJDK JRE
FROM openjdk:8-jre-alpine

ARG port
RUN test -n "$port" || (echo "Please provide the build-argument 'port'" && false)


ARG service_url
RUN test -n "$service_url" || (echo "Please provide the build-argument 'service_url'" && false)

COPY  target/scala-2.13/TweetAPI-assembly-0.1.0-SNAPSHOT.jar /TweetAPI-assembly-0.1.0-SNAPSHOT.jar
# run application with this command line 
ENV SERVICE_URL $service_url
ENV PORT $port
CMD ["/usr/bin/java", "-jar",  "/TweetAPI-assembly-0.1.0-SNAPSHOT.jar"]