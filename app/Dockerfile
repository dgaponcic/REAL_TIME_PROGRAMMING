FROM elixir
WORKDIR /app
COPY . .

# RUN mix deps.get && \\
#     mix run --no-halt

RUN mix local.hex --force
RUN mix deps.get
CMD mix run --no-halt
