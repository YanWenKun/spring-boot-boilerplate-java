FROM java:11
EXPOSE 8080
ARG JAR_FILE
ADD target/${JAR_FILE} /demo.jar
ENTRYPOINT ["java", "-jar","/demo.jar"]
