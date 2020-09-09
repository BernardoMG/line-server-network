FROM ruby:2.6.5

WORKDIR /app

ADD Gemfile ./Gemfile
RUN gem install bundler
RUN bundle install

ADD . /app

EXPOSE 8080
