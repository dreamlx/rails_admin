# README

## 使用说明

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


```
    下载配置后, 从 https://github.com/dreamlx/rails_admin/tree/master/lib/tasks
    下载策略文件夹

    配置文件 configN.yml 和 main.py 在同一个目录
    

```
执行:

        python main.py config1.yml