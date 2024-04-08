FROM julia:bullseye

RUN julia -e 'using Pkg; Pkg.add("Statsd")'

WORKDIR /opt/app
COPY ./src/ ./

CMD ["julia", "--threads=4", "main.jl"]