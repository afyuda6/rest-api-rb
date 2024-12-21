FROM ruby:3.3

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    sqlite3 \
    libsqlite3-dev \
    curl \
    git \
    unzip \
    libreadline-dev \
    libssl-dev \
    zlib1g-dev \
    libgdbm-dev \
    libncurses5-dev \
    libffi-dev \
    libyaml-dev \
    libreadline-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libicu-dev \
    libffi-dev \
    libgdbm-dev \
    libncurses5-dev \
    libtool \
    automake \
    bison \
    libxslt-dev \
    && rm -rf /var/lib/apt/lists/*

RUN gem install sqlite3 thin

WORKDIR /rest-api-rb

COPY . /rest-api-rb

EXPOSE 8080

CMD ["ruby", "main.rb"]