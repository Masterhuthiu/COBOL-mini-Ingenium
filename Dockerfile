FROM openjdk:11

# Cài Maven để build
RUN apt-get update && apt-get install -y maven git && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN git clone https://github.com/opensourcecobol/Open-COBOL-ESQL-4j.git && \
    cd Open-COBOL-ESQL-4j && \
    mvn clean install

# Copy ứng dụng COBOL4J của bạn
WORKDIR /app
COPY . .

# Chạy ứng dụng COBOL4J (ví dụ jar)
CMD ["java", "-jar", "target/your-cobol4j-app.jar"]
