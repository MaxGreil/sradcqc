FROM ubuntu:21.04
MAINTAINER Maximilian Greil

# Install procps so that Nextflow can poll CPU usage and
# deep clean the apt cache to reduce image/layer size
RUN apt-get update && \
    apt-get install -y wget pigz procps locales && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* && \
    # For MultiQC
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# For MultiQC 
ENV LANG en_US.UTF-8

RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    mkdir -p /opt && \
    sh miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy
    
ENV PATH="/opt/conda/bin/:$PATH"

COPY environment.yml /

RUN conda env create -f /environment.yml && \
    conda clean -a

ENV PATH="/opt/conda/envs/maxgreil-sradcqc/bin/:$PATH"

