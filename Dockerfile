FROM ruby:3.3

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    sqlite3 libsqlite3-dev libssl-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN gem install sqlite3 thin

WORKDIR /rest-api-rb

COPY . /rest-api-rb

EXPOSE 8080

CMD ["ruby", "main.rb"]
