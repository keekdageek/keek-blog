---
title:  "Load Testing with Cucumber PhantomJS and Docker Swarm, Part 1"
date:   2015-02-08 05:15:29
comments: True
tags: cucumber, phantomjs, docker swarm, ruby
---

Historically load testing had been pretty straightforward.  Get a list of urls usually from the weblogs and use tools like Siege, Apache Benchmark and JMeter and your off to the races.  This is a valid approach for load testing webservices or sites with that don't do alot of javascript rendering, but javascript heavy sites change the dynamics of your load testing.  Load tests need to open a browser, render the javascript and click on widgets. This two part blog is a simple example of creating load with Cucumber PhantomJS and an array of asynchronous clients on Docker containers.

For development I'm used Ubuntu 13.10 but also have it working with MacOS X Yosemite.  I'll also be referencing my [phantomjs-load](https://github.com/keekdageek/phantomjs-load){:target="_blank"} repo which has the complete code, individual sections will reference particular tags as the project evolves.

 Part 1 describes the initial setup with all the major components working and a simple test.  Part 2 uses the tests with Docker Swarm to create load with X clients running tests for X duration.

## Getting Started w/ Cucumber and PhantomJS

[part1.a](https://github.com/keekdageek/phantomjs-load/tree/part1.a){:target="_blank"}

Initially we will setup to run Cucumber and PhantomJS locally.  This setup was heavily inspired by Bastan Krol's blog on the same subject, [https://blog.codecentric.de/en/2013/08/cucumber-capybara-poltergeist](https://blog.codecentric.de/en/2013/08/cucumber-capybara-poltergeist/){:target="_blank"}.

Ruby 2.1 - Assumes Ruby 2.1, haven't tested with other versions.

PhantomJS - I've installed PhantomJS successfully with npm, keep in mind if you use a more recent version of Ubuntu you'll need to symbolic link /usr/bin/node to /usr/bin/nodejs.

~~~
npm install -g phantomjs
~~~

If your having issues installing, reference the [Dockerfile](https://github.com/keekdageek/phantomjs-load/blob/master/Dockerfile){:target="_blank"} for various dependencies to successfully install.  With the MacOS X `brew install phantomjs` worked fine.  The following is a snippet on how to install on Ubuntu 14.04

~~~
RUN apt-get install -y \
  software-properties-common \
  python-software-properties

RUN apt-add-repository ppa:brightbox/ruby-ng -y
RUN apt-get update

RUN apt-get install -y \
 ruby2.1 \
 ruby2.1-dev \
 build-essential \
 zlib1g-dev \
 libxslt-dev \
 libxml2-dev \
 npm \
 libfreetype6 \
 libfontconfig

RUN ln -s /usr/bin/nodejs /usr/bin/node

RUN gem install bundler
RUN npm install -g phantomjs
~~~    

Once installed test and make sure Cucumber is working headless and IN_BROWSER.

~~~
bundle
~~~

The the following two commands will visit Google News, click on Sports section and assert the text "Sports scores" exists.

~~~
bundle exec cucumber
IN_BROWSER=true bundle exec cucumber
~~~

NOTE:  Initially this didn't work with Firefox 35, so you may need to downgrade to Firefox 34 to get the Selenium driver working.

## Docker

[part1.b](https://github.com/keekdageek/phantomjs-load/tree/part1.b){:target="_blank"}


Docker Swarm requires the host's containers to have Docker 1.4.1 installed, if you previously installed docker you'll need to reinstall.

~~~
sudo su
curl https://get.docker.io/gpg | apt-key add -
echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list
sudo apt-get update
apt-get install lxc-docker
docker -v
~~~

MacOS X's boot2docker installs docker 1.4.1 as well.

~~~
boot2docker init
boot2docker start
$(boot2docker shellinit)
~~~

Next we'll build the image and run tests in the container.

~~~
./docker_build.sh
...
docker run -i -t keekdageek/phantomjs-load  bundle exec cucumber
                                                                                                      ⏎
@javascript
Feature: Google News Example
  As a user
  I view google news sports
  so that I get the latest chisme

  Scenario: Google news sports             # hello_world/google_news.feature:6
    Given I visit "http://news.google.com" # step_definitions/base_steps.rb:2
    When I click "Sports"                  # step_definitions/base_steps.rb:6
    Then I should see "Sports scores"      # step_definitions/base_steps.rb:10

1 scenario (1 passed)
3 steps (3 passed)
0m2.306s
~~~


Now Cucumber, PhantomJS and Docker are working in harmony locally.  In the next Part we'll integrate Docker Swarm and an example of inducing load with cucumber tests or a command line.




