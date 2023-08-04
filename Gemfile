# frozen_string_literal: true

source "https://nexus.sbmt.io/repository/rubygems/"

gemspec

gem "anyway_config", git: "https://github.com/palkan/anyway_config.git", branch: "master"

source "https://nexus.sbmt.io/repository/ruby-gems-sbermarket/" do
  gem "sbmt-waterdrop", ">= 2.5.3.1"

  group :development, :test do
    gem "sbmt-dev", ">= 0.7.0"
  end
end
