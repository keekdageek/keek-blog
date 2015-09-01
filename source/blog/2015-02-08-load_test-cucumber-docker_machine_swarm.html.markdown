---
title:  "Load Testing with Cucumber, Docker Machine and Swarm"
date:   2015-02-08 05:15 UTC
tags: cucumber, docker swarm, docker machine, ruby, load testing
description: Working example of using Cucumber with Docker Machine and Docker Swarm to induce load.  Starts with executing Cucumber tests with Ruby, PhantomJS, followed by creating a Docker image and load testing with Docker Machine/Swarm.  
---

Historically load testing had been pretty straightforward.  Get a list of urls usually from the weblogs and use tools like Siege, Apache Benchmark and JMeter and your off to the races.  This is a valid approach for load testing webservices or sites with that don't do alot of javascript rendering, but javascript heavy sites change the dynamics of load testing.  Load tests need to open a browser, render the javascript and click on widgets. This two part blog is a simple example of creating load with Cucumber PhantomJS and an array of asynchronous clients on Docker containers.

For development I'm used Ubuntu 14.04.  I'll also be referencing my [phantomjs-load](https://github.com/keekdageek/phantomjs-load){:target="_blank"} repo which has the complete code, individual sections will reference particular tags as the project evolves.

## Getting Started w/ Cucumber and PhantomJS

[cucumber-docker/hello-cucumber](https://github.com/keekdageek/cucumber-docker/tree/hello-cucumber){:target="_blank"}

Initially setup the environment to run Cucumber and PhantomJS locally.  This is heavily inspired by Bastan Krol's blog on the same subject, [https://blog.codecentric.de/en/2013/08/cucumber-capybara-poltergeist](https://blog.codecentric.de/en/2013/08/cucumber-capybara-poltergeist/){:target="_blank"}.  Eventually you can use Docker to install and run these dependencies.

**Ruby 2.2** - You can use either rbenv or rvm, but you'll want to keep the version consistent with the ruby version in the Docker image.

**PhantomJS** - On ubuntu install PhantomJS with npm, must be root user.

~~~
apt-get install npm
[...]
ln -s /usr/bin/nodejs /usr/bin/node
npm install -g phantomjs
[...]
phantomjs --version
 1.9.8
~~~

Homebrew's PhantomJS installation works out of the box.

~~~
brew install phantomjs
~~~

After installing ruby and phantomjs, clone the git repo at the respective tag, build, and test.

~~~
git clone git@github.com:keekdageek/cucumber-docker.git
git checkout -b test hello-cucumber
bundle
~~~

The the following two commands will visit Google News, click on Sports section and assert the text "Sports scores" exists.  Make sure they pass.

~~~
bundle exec cucumber
IN_BROWSER=true bundle exec cucumber
~~~

NOTE:  Initially IN_BROWSER didn't work with the latest Firefox, so you may need to downgrade to Firefox 34 to get the Selenium driver working.  [Firefox 34 releases](https://ftp.mozilla.org/pub/mozilla.org/firefox/releases/34.0.5/){:target='_blank'}

~~~
sudo su
apt-get purge firefox
cd /opt
rm -rf firefox
wget https://ftp.mozilla.org/pub/mozilla.org/firefox/releases/34.0.5/linux-x86_64/en-US/firefox-34.0.5.tar.bz2
tar xf firefox-34.0.5.tar.bz2
ln -s /opt/firefox/firefox-bin /usr/bin/firefox
rm firefox-34.0.5.tar.bz2
~~~

Finally disable automatic updates, open firefox then Preferences -> Advanced and click 'Never check for updates'

If your actively developing the Cucumber tests or any code related you can also continuously run the tests with [Guard](https://github.com/guard/guard).  This project uses the guard-cucumber and guard-bundler gems for autotesting.

~~~
bundle exec guard
~~~

## Docker

[cucumber-docker/docker](https://github.com/keekdageek/cucumber-docker/tree/docker){:target="_blank"}

Create a Docker image that can be used to execute the tests with PhantomJS.  This image is used to build the containers used in the load test by Docker Swarm.  To install Docker follow the official documentation for [Ubuntu](https://docs.docker.com/installation/ubuntulinux/){:target='_blank'} or [MacOS](https://docs.docker.com/installation/mac/).

The following Dockerfile creates the image to run the tests.

~~~
FROM ruby:2.2

# install npm
RUN apt-get update && apt-get install -y npm
RUN ln -s /usr/bin/nodejs /usr/bin/node

RUN npm install -g phantomjs

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

RUN bundle install

COPY . /usr/src/app
~~~

Checkout the tagged tagged branch and execute docker_build.sh to build and tag image (takes a few minutes).  , then run the tests.

~~~
./docker_build.sh
[...]
docker run -i -t keekdageek/cucumber-docker  bundle exec cucumber      
@javascript
Feature: Google News Example
  As a user
  I view google news sports
  so that I get the latest chisme

  Scenario: Google news sports             # features/hello_gnews/google_news.feature:6
    Given I visit "http://news.google.com" # features/step_definitions/base_steps.rb:2
useractiontype:  load
    When I click "Sports"                  # features/step_definitions/base_steps.rb:6
    Then I should see "Sports scores"      # features/step_definitions/base_steps.rb:10

1 scenario (1 passed)
3 steps (3 passed)
0m3.988s
~~~

With a successfully built image we can now setup a development environment with Docker.

## Develop with Docker Compose

[cucumber-docker/compose](https://github.com/keekdageek/cucumber-docker/tree/compose){:target="_blank"}

Running docker creates containers from the image everytime.  To keep the local code changes in sync with the container the local app directory is mounted on the container.  Additionally third party dependency changes (Gemfile) induce a complete reinstall of the gems with the current design.  The optimal solution is creating a volume container for ruby gems that is linked to the app container.  This will also keep the app images small since they share the gem container.

[Docker Compose](https://docs.docker.com/compose/){:target="_blank"} (previously Fig) provides a build and runtime environment where the container properties can be configured.  No need memorize and maintain the native docker commands.  Compose has many other convenient features which make developing with Docker significantly easier.  Follow official [docker-compose](https://docs.docker.com/compose/install/){:target="_blank"} installation instructions.

The following configuration creates the cucumber_app container with the local app directory mounted.  You'll notice it uses the image created in the previous step.  If the image parameter is replaced with 'build: .' then Compose would also build the image too.  I'm building the image manually because currently Compose doesn't let you change the image name being built and I want to store the images on DockerHub.

~~~
[...]
app:
  image: 'keekdageek/cucumber-docker:latest'
  volumes:
   - .:/usr/src/app/
[...]   
~~~

Now run the container and you'll see it runs the cucumber tests.

~~~
docker-compose up
[...]
app_1 | 
app_1 | 1 scenario (1 passed)
app_1 | 3 steps (3 passed)
app_1 | 0m3.710s
~~~

Make a change that breaks the test, and rerun

~~~
docker-compose up
[...]
app_1 | Failing Scenarios:
app_1 | cucumber features/hello_gnews/google_news.feature:6 # Scenario: Google news sports
app_1 | 
app_1 | 1 scenario (1 failed)
app_1 | 3 steps (1 failed, 1 skipped, 1 passed)
app_1 | 0m4.230s
cucumberdocker_app_1 exited with code 1
Gracefully stopping... (press Ctrl+C again to force)

~~~







