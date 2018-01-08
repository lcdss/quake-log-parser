# Quake Log Parser
## Introduction
This project is a very simple [rails](http://guides.rubyonrails.org/) application that loads a log file (Quake Arena 3) and displays a report about the games parsed. The parser used by this application is located [here](https://bitbucket.org/lcdss/quake-log-parser).

## Installation
If you have docker installed at your host machine you can easily run the application without dirty your machine. So just follow the steps bellow.

- Clone the project
  - `git clone https://github.com/lcdss/quake-log-parser.git`

- Build and run the docker container
  - `docker run -d -it --name quake-log-parser -p 3000:3000 -v "$PWD":/data/app lcdss/quake-log-parser /bin/bash`

- Access the container
  - `docker exec -it quake-log-parser bash`

- Install the project dependencies
  - `bundle`

- Run the rails server (puma)
  - `rails server`

- Now access the app at [http://localhost:3000](http://localhost:3000)

## Code Style
- [Ruby](https://github.com/bbatsov/ruby-style-guide)
- [Rails](https://github.com/bbatsov/rails-style-guide)
