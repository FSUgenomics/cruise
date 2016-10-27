# cruize

## a dockerized UCSC genome browser, customizable with simple google spreadsheets. This is still a work in progress and not ready for general use.

## why

The UCSC Genome Browser is a web-based genome browser widely used for viewing and sharing various types of genomic data mapped to reference genomes. [The browser hosted at UCSC](https://genome.ucsc.edu) is limited to a specific set of reference genomes. While "assembly hubs" allow users to utilize other reference genomes, research groups working with many genomes not hosted by UCSC may benefit from the installation of a self-hosted instance of the browser. Installing and maintaining a self-hosted instance of the browser is difficult and time-consuming, requiring extensive interactive use of the shell and mysql.

`cruize` was created to address these challenges, and is composed of a series of scripts and dockerfiles to facilitate the rapid and automated deployment of a genome browser installation and the loading of custom genomes and datasets.

## how

The data for a UCSC genome browser is stored in a series of mysql databases including a `hgcentral` database that defines the genomes loaded and contains user/session info, and a database for each genome that contains track data, metadata and display settings. `cruize` simplifies the creation and management of these databases by allowing users to enter genome and track metadata into a simple google spreadsheet tabulating information for each genome to be displayed, and another google spreadsheet tabulating what tracks are shown and how they are displayed. When the user wants to update the browser with new genomes, tracks, or track settings, `cruize` will download these spreadsheets and automatically rebuild the genome and track databases, negating the need for the user to directly interact with the mysql database.

## requirements

- [docker engine](https://www.docker.com/)

  ```bash
  curl -L https://get.docker.com | sh
  ```

- [docker compose](https://www.docker.com/products/docker-compose) (optional)

  ```bash
  curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
  chmod +x /usr/local/bin/docker-compose
  ```

## get

via git

```bash
git clone https://github.com/dvera/cruize && cd cruize
```

or grab the zipped source

```bash
curl -Lo master.zip https://github.com/FSUgenomics/cruize/archive/master.zip && unzip master.zip && rm -f master.zip && mv cruize-master cruize
```

## use

with compose:

```bash
docker-compose up
```

or without compose:

```bash

# create a bridge network for containers
docker network create cruize_nw

# start database container
docker run -d \
 -p 3306:3306 \
 --name cruize_sql \
 -h cruizesql \
 --env-file browser_config \
 -v $(pwd)/sqldb:/var/lib/mysql \
 -v $(pwd)/cruize_scripts:/usr/local/bin \
 --network cruize_nw \
 vera/cruize_sql

# start webserver container
docker run -d \
 -p 80:80 \
 --name cruize_www \
 -h cruizewww \
 --env-file browser_config \
 -v $(pwd)/gbdb:/gbdb:ro \
 -v $(pwd)/cruize_scripts:/usr/local/bin \
 --network cruize_nw \
 vera/cruize_www

# run admin container to update
 docker run -it \
  --name cruize_admin \
  -h cruizeadmin \
  --env-file browser_config \
  -v $(pwd)/gbdb:/gbdb \
  -v $(pwd)/cruize_scripts:/usr/local/bin \
  --network cruize_nw \
  vera/cruize_admin \
  update_browser
```

with cloud-init:

```yaml
#cloud-config
package_upgrade: true
package_update: true
runcmd:
  - curl https://get.docker.com/ | sh
  - curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
  - chmod +x /usr/local/bin/docker-compose
  - git clone --recursive https://github.com/fsugenomics/cruize /root/cruise
  - systemctl enable docker
  - systemctl start docker
```

## customize

refer to the [docs](http://dvera.github.io/cruize) to customize cruize.

## license

`cruize` downloads and installs the UCSC genome browser and associated tools, which are free for non-commercial use. The license for the UCSC genome browser can be found [here](https://genome-store.ucsc.edu/). `cruize` itself is licensed under the MIT license.

## to do

- blatServers
- bed files
- liftOver
- genomes menu
