FROM ruby:3.2.2

# Prepare working directory.
WORKDIR /ror
COPY ./ /ror
RUN gem install bundler
RUN bundle install

# Start app server.
CMD ["bundle", "exec", "rails", "server", "-e", "development", "-b", "0.0.0.0"]