FROM ruby:3.3.4

# Prepare working directory.
WORKDIR /ror
COPY ./ /ror

RUN gem install bundler
RUN bundle install

# Start app server.
CMD ["bundle", "exec", "rails", "server", "-e", "${RAILS_ENV:-production}", "-b", "0.0.0.0"]
