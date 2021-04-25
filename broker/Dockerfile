FROM elixir
WORKDIR /app
COPY app .
RUN mix local.hex --force
RUN mix deps.get -Y
RUN mix local.rebar --force
CMD mix run --no-halt
