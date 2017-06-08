FROM ruby:2.3-alpine
LABEL name "roamthepla.net"

RUN apk update && apk upgrade && apk add curl-dev ruby-dev build-base

WORKDIR /tmp
ADD Gemfile /tmp
ADD Gemfile.lock /tmp
RUN bundle install

WORKDIR /app
ADD . /app

EXPOSE 9292
CMD ["/usr/local/bin/bundle", "exec", "puma", "-t 8:16"]

