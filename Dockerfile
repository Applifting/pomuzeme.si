FROM ruby:2.6.3

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && apt-get install -y nodejs
RUN npm install -g yarn

RUN gem install bundler

ENV RAILS_ENV production
ENV RACK_ENV production
WORKDIR /app

COPY Gemfile .
COPY Gemfile.lock .

RUN bundle install

COPY . .

RUN RAILS_ENV=production SECRET_KEY_BASE=dummy bundle exec rake assets:precompile
EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
