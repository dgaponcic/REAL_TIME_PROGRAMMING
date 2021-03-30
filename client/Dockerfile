FROM elixir
WORKDIR /app
COPY app .
RUN mix local.hex --force
RUN mix deps.get
CMD mix run --no-halt
