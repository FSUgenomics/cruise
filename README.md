# cruise

## a dockerized UCSC genome browser, customizable with simple google spreadsheets

## why

The UCSC Genome Browser is a web-based genome browser widely used for viewing and sharing various types of genomic data mapped to reference genomes. [The browser hosted at UCSC](https://genome.ucsc.edu) is limited to a specific set of reference genomes. While "assembly hubs" allow users to utilize other reference genomes, research groups working with many genomes not hosted by UCSC may benefit from the installation of a self-hosted instance of the browser. Installing and maintaining a self-hosted instance of the browser is difficult and time-consuming, requiring extensive interactive use of the shell and mysql.

`cruise` was created to address these challenges, and is composed of a series of scripts and dockerfiles to facilitate the rapid and automated deployment of a genome browser installation and the loading of custom genomes and datasets.

## requirements

- docker engine

## get

install docker if not installed already:

```bash
curl -fsSL https://get.docker.com/ | sh
```

get `cruise` via github

```bash
git clone https://github.com/dvera/cruise && cd cruise
```

## use

with compose:

```bash
docker-compose up
# browser is now accessible at http://127.0.0.1/
```

without compose:

```bash
# make a directories on host to store the genome data and database
mkdir -p /gd
mkdir -p /db

# build the database and webserver images
(cd sql && docker build -t cruise_sql .)
(cd www && docker build -t cruise_www .)

# initiate a mysql database
docker run -d --name cruise_sql --env-file ../browser_config -v ${HOME}/cruisedb:/var/lib/mysql -p 80:80 cruise_sql

# start database and webserver containers
docker run -d --name cruise_sql --env-file ../browser_config -v ${HOME}/cruisedb:/var/lib/mysql -p 80:80 cruise_sql
docker run -d --name cruise_www --env-file ../browser_config --link sql:sql  www

# browser is now accessible on localhost port 80
```

## customize

The backend of the UCSC genome browser is a series of mysql database composed of an `hgcentral` database that defines the genomes loaded and contains user/session info, and a database for each genome that contains track data, metadata and display settings. `cruise` simplifies the creation and management of these databases and all their associated tables by allowing users to enter genome and track metadata into a simple google spreadsheet tabulating information for each genome to be displayed, and another google spreadsheet tabulating what tracks are shown and how they are displayed. When the user wants to update the browser with new genomes, tracks, or track settings, `cruise` will download these spreadsheets and automatically rebuild the genome and track databases, negating the need for the user to directly interact with the mysql database.

Configure the browser by editing browser_config file.

## licenses

`cruise` downloads and installs the UCSC genome browser and associated tools, which are free for non-commercial use. The license for the UCSC genome browser can be found [here](https://genome-store.ucsc.edu/).
