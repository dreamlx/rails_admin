# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

    58  docker-compose --version
    59  docker-compose up
    60  docker-compose run db:create
    61  docker-compose run rails db:create
    62  docker-compose run web rails db:create
    63  docker-compose run web rails db:migrate
    64  docker-compose run web rails db:seed
    65  docker-compose up -d

    http://127.0.0.1:3000/admin
    本地访问路径

    user:  admin@example.com
    pwd: password