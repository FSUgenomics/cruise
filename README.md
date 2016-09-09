# cruise

## a dockerized UCSC genome browser customizable with simple google spreadsheets

## requirements

- docker engine

## get

```bash
git clone https://github.com/dvera/cruise && cd cruise
```

## use

with compose:

```bash
docker-compose up
```

without compose:

```bash
(cd sql && sudo docker build --label cruise_sql .)
(cd www && sudo docker build --label cruise_www .)
(cd sql docker run -d --name sql --env=file ../browser_config -p 80:80 cruise_sql)
(cd sql docker run -d --name www --env=file ../browser_config --link sql:sql  www)
# browser is now accessible on localhost port 80
```

## customize

The backend of the UCSC genome browser is a series of mysql database composed of an `hgcentral` database that defines the genomes loaded and contains user/session info, and a database for each genome that contains track data, metadata and display settings. `cruise` simplifies the creation and management of these databases and all their associated tables by allowing users to enter genome and track metadata into a simple google spreadsheet tabulating information for each genome to be displayed, and another google spreadsheet tabulating what tracks are shown and how they are displayed. When the user wants to update the browser with new genomes, tracks, or track settings, `cruise` will download these spreadsheets and automatically rebuild the genome and track databases, negating the need for the user to directly interact with the mysql database.

Configure the browser by editing browser_config file.
