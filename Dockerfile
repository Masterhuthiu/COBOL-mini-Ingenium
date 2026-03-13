FROM openjdk:11-jdk

# Cài Maven để build
RUN apt-get update && apt-get install -y maven git && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN git clone https://github.com/opensourcecobol/Open-COBOL-ESQL-4j.git && \
    cd Open-COBOL-ESQL-4j && \
    mvn clean install

WORKDIR /app
COPY . .

CMD ["java", "-jar", "target/your-cobol4j-app.jar"]
