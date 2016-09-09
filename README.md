## get

Via git

```bash
git clone https://github.com/dvera/cruise && cd cruise
```

## configure

Configure the browser by editing browser_config

## use

### with compose:

```bash
docker-compose up
```

### without compose:

Build database and webserver images

```bash
(cd sql && sudo docker build --label cruise_sql . )
(cd www && sudo docker build --label cruise_www .)
```

Run containers
```
(cd sql docker run -d --name sql --env=file ../browser_config cruise_sql)
(cd sql docker run -d --name www --env=file ../browser_config --link sql:sql cruise_www)
```

## customize
