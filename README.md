# sradcqc

Proof of concept of a SRA to compressed FASTQ (including quality control) pipeline with Nextflow.

## Prerequisites

* Unix-like OS (Linux, macOS, etc.)
* [Java](http://jdk.java.net/) 8 or later
* [Docker](https://www.docker.com/) engine 1.10.x (or later)
* Working internet connection

## Table of Contents

* [Quick start](#Quick-start)
* [Installation](#Installation)
* [Arguments](#Arguments)
* [Documentation](#Documentation)

### Quick start

You must give in the SRA ID to download the .fastq files from. Optionally, you can specify the Nextflow output directory with a flag. By default, all resulting files will be saved in folder `data`.

Example run:
```
nextflow run main.nf --sra_id SRR000001
```

## Installation

Clone this repository with the following command:

```
git clone https://github.com/maxgreil/sradcqc && cd sradcqc
```

Then, install Nextflow by using the following command:

```
curl https://get.nextflow.io | bash
```

The above snippet creates the `nextflow` launcher in the current directory.

Finally pull the following Docker container:

```
docker pull maxgreil/sradcqc
```

Alternatively, you can build the Docker Image yourself using the following command:

```
cd docker && docker image build . -t maxgreil/sradcqc
```

## Arguments

### Required Arguments
| Argument  | Usage                            | Description                                                          |
|-----------|----------------------------------|----------------------------------------------------------------------|
| --sra_id  | \<id\>                           | SRA ID to download the .fastq files from                             |

### Optional Arguments
| Argument  | Usage                            | Description                                                          |
|-----------|----------------------------------|----------------------------------------------------------------------|
| --outdir  | \<folder\>                       | Directory to save .fastq.gz files                                    |

## Documentation

This pipeline is designed to download all files given a SRA ID in .fastq file format, compress all .fastq files to .fastq.gz and finally do a quality control of the compressed files.

### Pipeline overview

The pipeline is built using [Nextflow](https://www.nextflow.io/)
and processes data using the following steps:

* [fasterq-dump](https://github.com/ncbi/sra-tools/blob/master/tools/fasterq-dump/readme.txt) - extract the fastq file[s] from a sample
* [pigz](https://zlib.net/pigz/) - compress fastq file[s] to .gz
* [FastQC](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/) - read quality control
* [MultiQC](https://multiqc.info) - aggregate report, describing results of the whole pipeline
