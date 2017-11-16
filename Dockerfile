FROM ruby:2.3

RUN mkdir /api_gatewayc
WORKDIR /api_gatewayc

ADD Gemfile /api_gatewayc/Gemfile
ADD Gemfile.lock /api_gatewayc/Gemfile.lock

RUN bundle install
ADD . /api_gatewayc
