# cruise

## a dockerized UCSC genome browser, customizable with simple google spreadsheets

## why

The UCSC Genome Browser is a web-based genome browser widely used for viewing and sharing various types of genomic data mapped to reference genomes. [The browser hosted at UCSC](https://genome.ucsc.edu) is limited to a specific set of reference genomes. While "assembly hubs" allow users to utilize other reference genomes, research groups working with many genomes not hosted by UCSC may benefit from the installation of a self-hosted instance of the browser. Installing and maintaining a self-hosted instance of the browser is difficult and time-consuming, requiring extensive interactive use of the shell and mysql.

`cruise` was created to address these challenges, and is composed of a series of scripts and dockerfiles to facilitate the rapid and automated deployment of a genome browser installation and the loading of custom genomes and datasets.

## how

The data for a UCSC genome browser is stored in a series of mysql databases including a `hgcentral` database that defines the genomes loaded and contains user/session info, and a database for each genome that contains track data, metadata and display settings. `cruise` simplifies the creation and management of these databases by allowing users to enter genome and track metadata into a simple google spreadsheet tabulating information for each genome to be displayed, and another google spreadsheet tabulating what tracks are shown and how they are displayed. When the user wants to update the browser with new genomes, tracks, or track settings, `cruise` will download these spreadsheets and automatically rebuild the genome and track databases, negating the need for the user to directly interact with the mysql database.

## requirements

- [docker engine](https://www.docker.com/)
- [docker compose](https://www.docker.com/products/docker-compose) (optional)

## get

via git

```bash
git clone https://github.com/dvera/cruise && cd cruise
```

or grab the zipped source

```bash
curl -Lo master.zip https://github.com/FSUgenomics/cruise/archive/master.zip && unzip master.zip && rm -f master.zip && mv cruise-master cruise
```

## use

with compose:

```bash
docker-compose up
```

or without compose:

```bash

# build the database and webserver images
(cd sql && docker build -t cruise_sql .)
(cd www && docker build -t cruise_www .)

# create a bridge network for containers
docker network create cruise_nw

# start database container
docker run -it \
 -p 3306:3306 \
 --name cruise_sql \
 -h cruisesql \
 --env-file browser_config \
 -v $(pwd)/gbdb:/gbdb -v $(pwd)/sqldb:/var/lib/mysql \
 --network cruise_nw \
 cruise_sql initiate

# start webserver container
docker run -d \
 -p 80:80 \
 --name cruise_www \
 -h cruisewww \
 --env-file browser_config \
 -v $(pwd)/gbdb:/gbdb \
 --network cruise_nw \
 cruise_www
```

refer to the [docs](http://dvera.github.io/cruise) for production usage

## customize

Configure the browser by editing browser_config file.

## license

`cruise` downloads and installs the UCSC genome browser and associated tools, which are free for non-commercial use. The license for the UCSC genome browser can be found [here](https://genome-store.ucsc.edu/). `cruise` itself is licensed under the MIT license.

## to do

- blatServers
- bed files
- liftOver
- genomes menu
