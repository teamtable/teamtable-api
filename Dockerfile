FROM ruby:2.7.8-bullseye

WORKDIR /app

ENV RAILS_ENV=development \
    BUNDLE_WITHOUT=production \
    PORT=3001

COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 1.17.3
RUN bundle _1.17.3_ install --without production

COPY . .

EXPOSE 3001

CMD ["bash", "-lc", "bundle exec rails db:migrate && bundle exec rails db:seed && bundle exec rails server -b 0.0.0.0 -p 3001"]
