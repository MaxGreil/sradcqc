# sradcqc

Proof of concept of a SRA to trimmed FASTQ (including quality control) pipeline with Nextflow.

## Prerequisites

* Unix-like OS (Linux, macOS, etc.)
* [Java](https://openjdk.java.net) version 8
* [Docker](https://docs.docker.com/engine/install/) engine 1.10.x (or later)
* Working internet connection

## Table of Contents

* [Quick start](#Quick-start)
* [Installation](#Installation)
* [Arguments](#Arguments)
* [Documentation](#Documentation)

### Quick start

You have two input methods:

```
nextflow run main.nf --sra_id SRR000001
```

You can give in the SRA ID to download the files from directly. If the entered SRA ID belongs to a run, all .sra files belonging to the same experiment will be downloaded, too.

```
nextflow run main.nf --input input/example.tsv
```

Alternatively, you can give in the SRA ID to download the files from via table `input/example.tsv`. Only these specified SRA IDs will be downloaded.

Optionally, you can specify the Nextflow output directory with flag `--outdir <folder>`. By default, all resulting files will be saved in folder `output` and folder `info` will contain all information about the last run nextflow session.

Potential SRA IDs for download can be inspected using the [SRA Explorer](https://sra-explorer.info/).

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
| --input   | \<id\>                           | Table with SRA IDs to download the .fastq files from                 |

### Optional Arguments
| Argument  | Usage                            | Description                                                          |
|-----------|----------------------------------|----------------------------------------------------------------------|
| --outdir  | \<folder\>                       | Directory to save .fastq.gz files                                    |

## Documentation

This pipeline is designed to:
- download all files given a SRA ID in .fastq file format
- compress all .fastq files to .fastq.gz and finally
- do a quality control of the compressed files

### Pipeline overview

The pipeline is built using [Nextflow](https://www.nextflow.io/)
and processes data using the following steps:

1. [entrez-direct](https://www.ncbi.nlm.nih.gov/books/NBK179288/) - retrieve identifiers from SRA database
2. [prefetch](https://www.ncbi.nlm.nih.gov/sra/docs/sradownload/) - fetch data from SRA database in .sra file format
3. [fasterq-dump](https://github.com/ncbi/sra-tools/wiki/HowTo:-fasterq-dump) - extract the .fastq file[s] from a sample SRA ID
4. [pigz](https://zlib.net/pigz/) - compress downloaded .fastq file[s] to .gz
5. [bbduk](https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/bbduk-guide/) - trim adapters in .fastq file[s]
6. [FastQC](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/) - read quality control
7. [MultiQC](https://multiqc.info) - aggregate report, describing results of the whole pipeline
